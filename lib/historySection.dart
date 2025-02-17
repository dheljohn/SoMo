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

  final CollectionReference logsRef =
      FirebaseFirestore.instance.collection('sensor_logs');

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

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
    return "Invalid date";
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('h:mm a').format(dateTime);
    }
    return "Invalid time";
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<DocumentSnapshot>> groupedLogs = {};
    for (var log in _logs) {
      String date = _formatDate(log['timestamp']);
      if (!groupedLogs.containsKey(date)) {
        groupedLogs[date] = [];
      }
      groupedLogs[date]!.add(log);
    }

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

              ? Center(child: Text('No sensor history available.'))
              : ListView(
                  children: groupedLogs.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...entry.value.map((log) {
                          Map<String, dynamic> data =
                              log.data() as Map<String, dynamic>;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Card(
                              color: const Color.fromARGB(255, 249, 249, 249),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                title: Text(
                                  _formatTime(data['timestamp']),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8.0),
                                    Text(
                                      "Soil Moisture: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    Text(
                                      "Temperature: ${data['temperature']}°C",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                    Text(
                                      "Humidity: ${data['humidity']}%",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],

                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Sensor Log Details'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                'Temperature: ${data['temperature']}°C'),
                                            Text(
                                                'Humidity: ${data['humidity']}%'),
                                            Text(
                                                'Soil Moisture 1: ${data['moisture_1']}'),
                                            Text(
                                                'Soil Moisture 2: ${data['moisture_2']}'),
                                            Text(
                                                'Soil Moisture 3: ${data['moisture_3']}'),
                                            Text(
                                                'Soil Moisture 4: ${data['moisture_4']}'),
                                            Text(
                                                'Time: ${_formatTime(data['timestamp'])}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList()
                      ],
                    );
                  }).toList(),
                ),
    );
  }
}
