import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class HistoryDisplay extends StatefulWidget {
  @override
  _HistoryDisplayState createState() => _HistoryDisplayState();
}

class _HistoryDisplayState extends State<HistoryDisplay> {
  String selectedPlot = "Plot1"; // Default plot
  final List<String> plots = ["Plot1", "Plot2", "Plot3"];
  List<Map<String, dynamic>> sensorData = [];
  StreamSubscription<QuerySnapshot>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _sensorSubscription?.cancel();
    _sensorSubscription = FirebaseFirestore.instance
        .collection("Plots")
        .doc(selectedPlot)
        .collection("sensorData")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          sensorData = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    }, onError: (error) {
      print("Firestore Error: $error");
    });
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  // Format timestamp
  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }
    return "Invalid date";
  }

  // Generate and save CSV file
  Future<void> _downloadCSV() async {
    if (sensorData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No data to download!"),
      ));
      return;
    }

    // Request permission for storage access
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Storage permission denied"),
      ));
      return;
    }

    // Prepare CSV data
    List<List<String>> csvData = [
      [
        "Date",
        "Time",
        "Avg Moisture",
        "Humidity",
        "Temperature",
        "Moisture 1",
        "Moisture 2",
        "Moisture 3",
        "Moisture 4"
      ]
    ];

    for (var data in sensorData) {
      DateTime timestamp = data['timestamp'].toDate();
      String date = DateFormat('MMMM d, yyyy').format(timestamp);
      String time = DateFormat('h:mm a').format(timestamp);

      csvData.add([
        date,
        time,
        "${data['average_moisture']}%",
        "${data['humidity']}%",
        "${data['temperature']}°C",
        "${data['moisture_1']}",
        "${data['moisture_2']}",
        "${data['moisture_3']}",
        "${data['moisture_4']}",
      ]);
    }

    String csvString = const ListToCsvConverter().convert(csvData);

    try {
      // Get the REAL Downloads folder
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        throw "Downloads folder not found";
      }

      String filePath = "${directory.path}/sensor_data_${selectedPlot}.csv";
      File file = File(filePath);

      // Write CSV data to file
      await file.writeAsString(csvString);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("CSV saved to Downloads: $filePath"),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error saving file: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var data in sensorData) {
      String dateKey =
          DateFormat('MMMM d, yyyy').format(data['timestamp'].toDate());
      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }
      groupedData[dateKey]!.add(data);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Sensor Data History"),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadCSV,
          )
        ],
      ),
      body: Column(
        children: [
          // Dropdown for selecting plots
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedPlot,
              items: plots.map((plot) {
                return DropdownMenuItem(
                  value: plot,
                  child: Text(plot),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPlot = value;
                  });
                  _startListening();
                }
              },
            ),
          ),

          // Display Grouped Sensor Data
          Expanded(
            child: sensorData.isEmpty
                ? Center(child: Text("No data available"))
                : ListView(
                    children: groupedData.entries.map((entry) {
                      String date = entry.key;
                      List<Map<String, dynamic>> records = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date heading outside the cards
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              date,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 0, 73, 39)),
                            ),
                          ),

                          // List of sensor records under this date
                          ...records.map((data) {
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('h:mm a').format(
                                          data['timestamp']
                                              .toDate()), // e.g., 3:00 PM
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromARGB(
                                              255, 0, 0, 0)),
                                    ),
                                    Divider(
                                      color: const Color.fromARGB(
                                          255, 115, 115, 115),
                                      thickness: 1,
                                    ),
                                    Text(
                                        "Avg Moisture: ${data['average_moisture']}%",
                                        style: TextStyle(fontSize: 14)),
                                    Text("Humidity: ${data['humidity']}%",
                                        style: TextStyle(fontSize: 14)),
                                    Text(
                                        "Temperature: ${data['temperature']}°C",
                                        style: TextStyle(fontSize: 14)),
                                    Text(
                                      "Moisture Sensors: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
