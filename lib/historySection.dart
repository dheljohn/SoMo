import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDisplay extends StatefulWidget {
  @override
  _HistoryDisplayState createState() => _HistoryDisplayState();
}

class _HistoryDisplayState extends State<HistoryDisplay> {
  String selectedPlot = "Plot1"; // Default plot
  final List<String> plots = ["Plot1", "Plot2", "Plot3"];
  List<Map<String, dynamic>> sensorData = [];
  StreamSubscription<QuerySnapshot>? _sensorSubscription; // Nullable

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    print("Listening to: $selectedPlot");

    _sensorSubscription
        ?.cancel(); // Cancel existing listener before starting a new one
    _sensorSubscription = FirebaseFirestore.instance
        .collection("Plots")
        .doc(selectedPlot)
        .collection("sensorData")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snapshot) {
      print("Data received: ${snapshot.docs.length} documents");

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

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }
    return "Invalid date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensor Data History")),
      body: Column(
        children: [
          // Dropdown to select Plot
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
                  _startListening(); // Restart listener after setting state
                }
              },
            ),
          ),

          // Display Sensor Data
          Expanded(
            child: sensorData.isEmpty
                ? Center(child: Text("No data available"))
                : ListView.builder(
                    itemCount: sensorData.length,
                    itemBuilder: (context, index) {
                      var data = sensorData[index];

                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(
                              "Timestamp: ${formatTimestamp(data['timestamp'])}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Avg Moisture: ${data['average_moisture']}"),
                              Text("Humidity: ${data['humidity']}"),
                              Text("Temp: ${data['temperature']}°C"),
                              Text(
                                  "Moisture Sensors: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
