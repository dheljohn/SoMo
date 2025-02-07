import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/log_generator.dart';
import 'package:soil_monitoring_app/models/sensor_log.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<SensorLog> sensorLogs = [];
  Map<String, SensorLog?> lastLogs = {};
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startLogging();
  }

  void _startLogging() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _checkSensorReadings();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkSensorReadings() {
    final dataProvider = DataProvider.of(context);

    if (dataProvider == null) {
      print('DataProvider is null');
      return;
    }

    Map<String, double> sensorReadings = {
      'Sensor 1': dataProvider.temperatureValue,
      'Sensor 2': dataProvider.humidityValue,
      'Sensor 3': dataProvider.moistureA,
      'Sensor 4': dataProvider.moistureS1,
      'Sensor 5': dataProvider.moistureS2,
      'Sensor 6': dataProvider.moistureS3,
      'Sensor 7': dataProvider.moistureS4,
    };

    print('Sensor Readings: $sensorReadings');

    // Generate new logs based on the readings and the last logs
    List<SensorLog> newLogs = generateLogs(sensorReadings, lastLogs);

    setState(() {
      for (var newLog in newLogs) {
        var lastLog = lastLogs[newLog.sensorId];

        // If there's no previous log (first log for the sensor) or the log's description/status has changed
        if (lastLog == null ||
            lastLog.description != newLog.description ||
            lastLog.status != newLog.status) {
          // If the previous log exists and is ongoing (endTimestamp is null), we need to mark its end
          if (lastLog != null && lastLog.endTimestamp == null) {
            lastLogs[newLog.sensorId] =
                lastLog.copyWith(endTimestamp: DateTime.now());
          }

          // Add the new log to the logs list
          sensorLogs.add(newLog);

          // Update the lastLogs map with the new log
          lastLogs[newLog.sensorId] = newLog;
        } else {
          // If the log hasn't changed, only update the end timestamp for the ongoing log
          lastLogs[newLog.sensorId] =
              lastLog.copyWith(endTimestamp: DateTime.now());
        }
      }
    });
  }

  Future<void> _exportToCsv() async {
    List<List<String>> csvData = [
      [
        'Start Timestamp',
        'End Timestamp',
        'Sensor ID',
        'Description',
        'Status'
      ],
      ...sensorLogs.map((log) => log.toCsv())
    ];

    String csvString = const ListToCsvConverter().convert(csvData);

    try {
      if (await Permission.storage.request().isGranted) {
        Directory directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        final String path = '${directory.path}/sensor_logs.csv';
        final File file = File(path);
        await file.writeAsString(csvString);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("CSV file saved to: $path")),
        );

        print("CSV file saved at: $path");

        // ✅ Automatically open the file
        await OpenFile.open(path);
      } else {
        print("Storage permission denied!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Permission denied to save file")),
        );
      }
    } catch (e) {
      print("Error exporting CSV: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to export CSV")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportToCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // ✅ Allow vertical scrolling
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Start Timestamp')),
                    DataColumn(label: Text('End Timestamp')),
                    DataColumn(label: Text('Sensor ID')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: sensorLogs.map((log) {
                    return DataRow(cells: [
                      DataCell(Text(log.startTimestamp.toIso8601String())),
                      DataCell(Text(
                          log.endTimestamp?.toIso8601String() ?? 'ongoing')),
                      DataCell(Text(log.sensorId)),
                      DataCell(Text(log.description)),
                      DataCell(Text(log.status)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
