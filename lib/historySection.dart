import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryLogsScreen extends StatefulWidget {
  const HistoryLogsScreen({Key? key}) : super(key: key);

  @override
  _HistoryLogsScreenState createState() => _HistoryLogsScreenState();
}

class _HistoryLogsScreenState extends State<HistoryLogsScreen> {
  String? selectedPlot;
  List<String> plots = [];
  bool isLoading = true; // Add a loading flag

  @override
  void initState() {
    super.initState();
    fetchPlots();
  }

  Future<void> fetchPlots() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("Plots").get();
      setState(() {
        plots = snapshot.docs.map((doc) => doc.id).toList();
        if (plots.isNotEmpty) {
          selectedPlot = plots.first; // Default to the first plot
        }
        isLoading = false; // Data loaded
      });
    } catch (e) {
      print("Error fetching plots: $e");
      setState(() {
        isLoading = false;
      });
    }
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
      appBar: AppBar(title: Text("History Logs")),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedPlot,
                    hint: Text("Select Plot"),
                    isExpanded: true,
                    items: plots.map((plot) {
                      return DropdownMenuItem<String>(
                        value: plot,
                        child: Text(plot),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPlot = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: selectedPlot == null
                      ? Center(child: Text("Please select a plot"))
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("Plots")
                              .doc(selectedPlot)
                              .collection("sensorData")
                              .orderBy("timestamp", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text("No logs available."));
                            }

                            var logs = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: logs.length,
                              itemBuilder: (context, index) {
                                var log =
                                    logs[index].data() as Map<String, dynamic>;
                                DateTime timestamp =
                                    (log["timestamp"] as Timestamp).toDate();
                                String formattedDate =
                                    DateFormat("yyyy-MM-dd HH:mm")
                                        .format(timestamp);

                                return Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text("Date: $formattedDate"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Temperature: ${log['temperature']}°C"),
                                        Text("Humidity: ${log['humidity']}%"),
                                        Text(
                                            "Avg Moisture: ${log['average_moisture']}%"),
                                        Text(
                                            "Moisture 1: ${log['moisture_1']}%"),
                                        Text(
                                            "Moisture 2: ${log['moisture_2']}%"),
                                        Text(
                                            "Moisture 3: ${log['moisture_3']}%"),
                                        Text(
                                            "Moisture 4: ${log['moisture_4']}%"),
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
