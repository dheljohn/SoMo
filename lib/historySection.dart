import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

String interpretMoisture(double moisture) {
  if (moisture < 30) return "Low (Soil is dry, needs watering)";
  if (moisture < 60) return "Moderate (Soil is moist, good condition)";
  return "High (Soil is very wet, avoid overwatering)";
}

String interpretTemperature(double temp) {
  if (temp < 15) return "Cold (Risk of frost)";
  if (temp < 30) return "Optimal (Good growing conditions)";
  return "Hot (Plants may need extra water)";
}

String interpretHumidity(double humidity) {
  if (humidity < 40) return "Low (Dry air, may cause dehydration)";
  if (humidity < 70) return "Moderate (Ideal conditions)";
  return "High (Risk of fungal growth)";
}

class HistoryDisplay extends StatefulWidget {
  @override
  _HistoryDisplayState createState() => _HistoryDisplayState();
}

class _HistoryDisplayState extends State<HistoryDisplay> {
  String selectedPlot = "All"; // Default selection
  final List<String> plots = ["All", "Plot1", "Plot2", "Plot3"];
  List<Map<String, dynamic>> sensorData = [];
  StreamSubscription<QuerySnapshot>? _sensorSubscription;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? selectedDate;
  String selectedSortOrder = "Descending"; // Default sort order
  String selectedFilter = "None"; // Default filter
  bool isLoading = false; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      isLoading = true; // Start loading
    });

    print("Fetching data for: $selectedPlot");

    _sensorSubscription?.cancel();
    sensorData.clear();

    if (selectedPlot == "All") {
      await _fetchAllPlotsData();
    } else {
      await _fetchSinglePlotData(selectedPlot);
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  Future<void> _fetchSinglePlotData(String plot) async {
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
        _filterAndSortData();
      });
    }, onError: (error) {
      print("Firestore Error: $error");
    });
  }

  Future<void> _fetchAllPlotsData() async {
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
      sensorData = allData; //display all data
      //sensorData = allData.take(20).toList(); // fetch only 20 data by default
      _filterAndSortData();
    });
  }

  void _filterAndSortData() {
    List<Map<String, dynamic>> filteredData = List.from(sensorData);

    if (startDate != null && endDate != null) {
      filteredData = filteredData.where((data) {
        DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        return timestamp.isAfter(startDate!) && timestamp.isBefore(endDate!);
      }).toList();
    } else if (selectedDate != null) {
      filteredData = filteredData.where((data) {
        DateTime timestamp = (data['timestamp'] as Timestamp).toDate();
        return DateFormat('yyyy-MM-dd').format(timestamp) ==
            DateFormat('yyyy-MM-dd').format(selectedDate!);
      }).toList();
    }

    if (selectedFilter != "None") {
      filteredData = filteredData.where((data) {
        double value;
        switch (selectedFilter) {
          case "High Moisture":
            value = data['average_moisture'];
            return value > 60;
          case "Low Moisture":
            value = data['average_moisture'];
            return value < 30;
          case "High Temperature":
            value = data['temperature'];
            return value > 30;
          case "Low Temperature":
            value = data['temperature'];
            return value < 15;
          case "High Humidity":
            value = data['humidity'];
            return value > 70;
          case "Low Humidity":
            value = data['humidity'];
            return value < 40;
          case "None":
          default:
            return true;
        }
      }).toList();

      filteredData.sort((a, b) {
        double valueA, valueB;
        switch (selectedFilter) {
          case "High Moisture":
          case "Low Moisture":
            valueA = a['average_moisture'];
            valueB = b['average_moisture'];
            break;
          case "High Temperature":
          case "Low Temperature":
            valueA = a['temperature'];
            valueB = b['temperature'];
            break;
          case "High Humidity":
          case "Low Humidity":
            valueA = a['humidity'];
            valueB = b['humidity'];
            break;
          default:
            valueA = 0;
            valueB = 0;
        }
        return selectedSortOrder == "Ascending"
            ? valueA.compareTo(valueB)
            : valueB.compareTo(valueA);
      });
    } else {
      filteredData.sort((a, b) {
        DateTime dateA = (a['timestamp'] as Timestamp).toDate();
        DateTime dateB = (b['timestamp'] as Timestamp).toDate();
        return selectedSortOrder == "Ascending"
            ? dateA.compareTo(dateB)
            : dateB.compareTo(dateA);
      });
    }

    setState(() {
      sensorData = filteredData; // fetch all data
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        startDate = null;
        endDate = null;
      });
      _fetchData();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedDate = null;
      });
      _fetchData();
    }
  }

  Future<void> _showDatePickerDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Date Option'),
          content: Text.rich(
            TextSpan(
              text: 'Pick a date format: ',
              children: <TextSpan>[
                TextSpan(
                  text: 'one specific date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' or '),
                TextSpan(
                  text: 'range ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: 'with start and end dates'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Single Date'),
              onPressed: () {
                Navigator.of(context).pop();
                _selectDate(context);
              },
            ),
            TextButton(
              child: Text('Date Range'),
              onPressed: () {
                Navigator.of(context).pop();
                _selectDateRange(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _downloadCSV() async {
    var status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission denied")),
      );

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
    Directory? directory = await getExternalStorageDirectory();

    if (directory == null) {
      throw "Failed to get storage directory";
    }

    String fileName = selectedPlot == "All"
        ? "all_plots_sensor_data.csv"
        : "${selectedPlot}_sensor_data.csv";
    String filePath = "${directory.path}/$fileName";
    File file = File(filePath);

    await file.writeAsString(csvString);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("CSV saved: $filePath"),
    ));

    // Open the file after download
    OpenFile.open(filePath);
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
    }
    return "Invalid date";
  }

  Widget moistureIndicator(double moisture) {
    Color color;
    String interpretation;

    if (moisture < 30) {
      color = Colors.red;
      interpretation = "Low (Soil is dry, needs watering)";
    } else if (moisture < 60) {
      color = Colors.orange;
      interpretation = "Moderate (Soil is moist, good condition)";
    } else {
      color = Colors.green;
      interpretation = "High (Soil is very wet, avoid overwatering)";
    }

    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 14),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            "Moisture: $moisture% - $interpretation",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget buildFilterDropdown() {
    return PopupMenuButton<String>(
      initialValue: selectedFilter,
      icon: Icon(
        Icons.filter_list,
      ),
      onSelected: (value) {
        setState(() {
          selectedFilter = value;
        });
        _fetchData();
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: "None",
            child: Text("None"),
          ),
          PopupMenuItem(
            value: "High Moisture",
            child: Text("High Moisture"),
          ),
          PopupMenuItem(
            value: "Low Moisture",
            child: Text("Low Moisture"),
          ),
          PopupMenuItem(
            value: "High Temperature",
            child: Text("High Temperature"),
          ),
          PopupMenuItem(
            value: "Low Temperature",
            child: Text("Low Temperature"),
          ),
          PopupMenuItem(
            value: "High Humidity",
            child: Text("High Humidity"),
          ),
          PopupMenuItem(
            value: "Low Humidity",
            child: Text("Low Humidity"),
          ),
        ];
      },
    );
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

    Color getMoistureColor(double moisture) {
      if (moisture < 30) return Colors.red; // Dry
      if (moisture < 60) return Colors.orange; // Moderate
      return Colors.green; // Good
    }

    Widget moistureIndicator(double moisture) {
      return Row(
        children: [
          Text("Moisture: $moisture%"),
          SizedBox(width: 5),
          Icon(Icons.circle, color: getMoistureColor(moisture), size: 14),
        ],
      );
    }

    return Scaffold(
      //appBar: AppBar(
      // title: Text("Sensor Data History"),
      // actions: [
      //   IconButton(
      //     icon: Icon(Icons.download),
      //     onPressed: _downloadCSV,
      //   ),
      // ],

      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Date Picker
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                // Dropdown for sorting order

                IconButton(
                  icon: Icon(
                    selectedSortOrder == "Ascending"
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  tooltip: selectedSortOrder == "Ascending"
                      ? "Sort Ascending"
                      : "Sort Descending",
                  onPressed: () {
                    setState(() {
                      selectedSortOrder = selectedSortOrder == "Ascending"
                          ? "Descending"
                          : "Ascending";
                    });
                    _filterAndSortData();
                  },
                ),

                // Dropdown for filtering
                buildFilterDropdown(),
                Flexible(
                  child: IconButton(
                    icon: Icon(Icons.date_range),
                    onPressed: () => _showDatePickerDialog(context),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: _downloadCSV,
                ),
              ],
            ),
          ),

          // Display Grouped Sensor Data
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : sensorData.isEmpty
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
                                      color:
                                          const Color.fromARGB(255, 0, 73, 39)),
                                ),
                              ),
                              ...records.map((data) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SensorDetailScreen(
                                                sensorData: data),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${data['plot']} - ${DateFormat('h:mm a').format(data['timestamp'].toDate())}",
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Divider(),
                                          moistureIndicator(
                                              data['average_moisture']),
                                          Text(
                                              "Temperature: ${data['temperature']}°C - ${interpretTemperature(data['temperature'])}"),
                                          Text(
                                              "Humidity: ${data['humidity']}% - ${interpretHumidity(data['humidity'])}"),
                                          Text(
                                              "Moisture Sensors: ${data['moisture_1']}, ${data['moisture_2']}, ${data['moisture_3']}, ${data['moisture_4']}"),
                                        ],
                                      ),
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

class SensorDetailScreen extends StatelessWidget {
  final Map<String, dynamic> sensorData;

  SensorDetailScreen({required this.sensorData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sensor Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Plot: ${sensorData['plot']}",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
                "Timestamp: ${DateFormat('yyyy-MM-dd h:mm a').format(sensorData['timestamp'].toDate())}"),
            SizedBox(height: 10),
            Text(
                "Temperature: ${sensorData['temperature']}°C - ${interpretTemperature(sensorData['temperature'])}"),
            Text(
                "Humidity: ${sensorData['humidity']}% - ${interpretHumidity(sensorData['humidity'])}"),
            SizedBox(height: 10),
            Text("Average Moisture: ${sensorData['average_moisture']}%"),
            Text("Moisture Sensor 1: ${sensorData['moisture_1']}%"),
            Text("Moisture Sensor 2: ${sensorData['moisture_2']}%"),
            Text("Moisture Sensor 3: ${sensorData['moisture_3']}%"),
            Text("Moisture Sensor 4: ${sensorData['moisture_4']}%"),
          ],
        ),
      ),
    );
  }
}
