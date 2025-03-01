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

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }
    return "Invalid date";
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
                setState(() {
                  selectedPlot = value!;
                });
              },
            ),
          ),

          // Stream Builder to fetch data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Plots")
                  .doc(selectedPlot)
                  .collection("sensorData")
                  .orderBy("timestamp", descending: true) // Sort by timestamp
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No data available"));
                }

                var sensorDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: sensorDocs.length,
                  itemBuilder: (context, index) {
                    var data = sensorDocs[index].data() as Map<String, dynamic>;

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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
