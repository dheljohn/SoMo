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
  String selectedPlot = "All"; // Default selection
  final List<String> plots = ["All", "Plot1", "Plot2", "Plot3"];
  List<Map<String, dynamic>> sensorData = [];
  StreamSubscription<QuerySnapshot>? _sensorSubscription;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    print("Fetching data for: $selectedPlot");

    _sensorSubscription?.cancel();
    sensorData.clear();

    if (selectedPlot == "All") {
      _fetchAllPlotsData();
    } else {
      _fetchSinglePlotData(selectedPlot);
    }
  }

  void _fetchSinglePlotData(String plot) {
    _sensorSubscription = FirebaseFirestore.instance
        .collection("Plots")
        .doc(plot)
        .collection("sensorData")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        sensorData = snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['plot'] = plot; // Add plot name
          return data;
        }).toList();
      });
    }, onError: (error) {
      print("Firestore Error: $error");
    });
  }

  void _fetchAllPlotsData() async {
    List<Map<String, dynamic>> allData = [];

    for (String plot in plots.where((p) => p != "All")) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Plots")
          .doc(plot)
          .collection("sensorData")
          .orderBy("timestamp", descending: true)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['plot'] = plot;
        allData.add(data);
      }
    }

    setState(() {
      sensorData = allData;
    });
  }

  Future<void> _downloadCSV() async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Storage permission denied"),
      ));
      return;
    }

    List<List<String>> csvData = [
      [
        "Plot",
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
      DateTime timestamp =
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      String date = DateFormat('MMMM d, yyyy').format(timestamp);
      String time = DateFormat('h:mm a').format(timestamp);

      csvData.add([
        data['plot'] ?? "Unknown Plot",
        date,
        time,
        "${data['average_moisture'] ?? "N/A"}%",
        "${data['humidity'] ?? "N/A"}%",
        "${data['temperature'] ?? "N/A"}°C",
        "${data['moisture_1'] ?? "N/A"}",
        "${data['moisture_2'] ?? "N/A"}",
        "${data['moisture_3'] ?? "N/A"}",
        "${data['moisture_4'] ?? "N/A"}",
      ]);
    }

    String csvString = const ListToCsvConverter().convert(csvData);

    Directory? directory = Directory('/storage/emulated/0/Download');
    if (!await directory.exists()) {
      throw "Downloads folder not found";
    }

    String fileName = selectedPlot == "All"
        ? "all_plots_sensor_data.csv"
        : "${selectedPlot}_sensor_data.csv";
    String filePath = "${directory.path}/$fileName";
    File file = File(filePath);

    await file.writeAsString(csvString);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("CSV saved to Downloads: $filePath"),
    ));
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }
    return "Invalid date";
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
          ),
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
                  _fetchData();
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
                                      "${data['plot']} - ${DateFormat('h:mm a').format(data['timestamp'].toDate())}",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Divider(),
                                    Text(
                                        "Avg Moisture: ${data['average_moisture']}%"),
                                    Text("Humidity: ${data['humidity']}%"),
                                    Text(
                                        "Temperature: ${data['temperature']}°C"),
                                    Text(
                                        "Moisture Sensors: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}"),
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
