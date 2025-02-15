import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class SensorHistoryScreen extends StatefulWidget {
  const SensorHistoryScreen({super.key});

  @override
  _SensorHistoryScreenState createState() => _SensorHistoryScreenState();
}

class _SensorHistoryScreenState extends State<SensorHistoryScreen> {
  List<DocumentSnapshot> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  void _fetchLogs() {
    FirebaseFirestore.instance
        .collectionGroup('logs')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _logs = snapshot.docs;
        _isLoading = false;
      });
    });
  }

  Future<void> _downloadCSV() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collectionGroup('logs').get();

    List<List<dynamic>> csvData = [
      [
        "Timestamp",
        "Temperature",
        "Humidity",
        "Soil Moisture 1",
        "Soil Moisture 2",
        "Soil Moisture 3",
        "Soil Moisture 4"
      ]
    ];

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      csvData.add([
        _formatTimestamp(data['timestamp']),
        data['temperature'] ?? '',
        data['humidity'] ?? '',
        data['moisture_1'] ?? '',
        data['moisture_2'] ?? '',
        data['moisture_3'] ?? '',
        data['moisture_4'] ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/sensor_logs.csv';
    final File file = File(path);
    await file.writeAsString(csv);

    OpenFile.open(path);
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    }
    return "Invalid date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadCSV,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No sensor history available.'))
              : ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        _logs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                          "Temperature: ${data['temperature']}°C, Humidity: ${data['humidity']}%"),
                      subtitle: Text(
                          "Soil Moisture: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}"),
                      trailing: Text(_formatTimestamp(data['timestamp'])),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Sensor Log Details'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Temperature: ${data['temperature']}°C',
                                  ),
                                  Text(
                                    'Humidity: ${data['humidity']}%',
                                  ),
                                  Text(
                                    'Soil Moisture 1: ${data['moisture_1']}',
                                  ),
                                  Text(
                                    'Soil Moisture 2: ${data['moisture_2']}',
                                  ),
                                  Text(
                                    'Soil Moisture 3: ${data['moisture_3']}',
                                  ),
                                  Text(
                                    'Soil Moisture 4: ${data['moisture_4']}',
                                  ),
                                  Text(
                                    'Timestamp: ${_formatTimestamp(data['timestamp'])}',
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Close'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}
