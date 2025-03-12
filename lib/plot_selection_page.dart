import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlotSelection extends StatefulWidget {
  @override
  _PlotSelectionState createState() => _PlotSelectionState();
}

class _PlotSelectionState extends State<PlotSelection> {
  final List<String> plots = ['Lettuce', 'Pechay', 'Mustard'];
  String? selectedPlot = 'Lettuce'; // Default to the first item
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDB = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadSavedPlot();
  }

  Future<void> _loadSavedPlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPlot = prefs.getString('selected_plot');

    setState(() {
      selectedPlot = (savedPlot != null && plots.contains(savedPlot))
          ? savedPlot
          : plots.first;
    });
  }

  Future<void> _savePlot(String plot) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_plot', plot);
    _savePlotToFirebase(plot);
  }

  void _savePlotToFirebase(String plot) async {
    await firestore.collection("selected_plots").doc("currentPlot").set({
      "plot": plot,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await realtimeDB.child("SelectedPlot").set({"plotName": plot});

    print("Plot selected: $plot");
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double screenHeight = queryData.size.height;
    double screenWidth = queryData.size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: screenWidth * 0.37,
          height: screenHeight * 0.07,
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, vertical: screenWidth * 0.02),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blueGrey, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: DropdownButton<String>(
            value: selectedPlot,
            dropdownColor: Colors.white,
            underline: SizedBox(),
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              color: Colors.blueGrey[800],
            ),
            items: plots.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(Icons.eco,
                        color: Colors.green, size: screenWidth * 0.05),
                    SizedBox(width: screenWidth * 0.02),
                    Text(value),
                  ],
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() {
                  selectedPlot = newValue;
                });
                _savePlot(newValue);
              }
            },
          ),
        ),
      ],
    );
  }
}
