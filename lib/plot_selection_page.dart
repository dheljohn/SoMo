import 'package:cloud_firestore/cloud_firestore.dart';   
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlotSelection extends StatefulWidget {
  @override
  _PlotSelectionState createState() => _PlotSelectionState();
}

class _PlotSelectionState extends State<PlotSelection> {
  final List<String> plots = ['Plot1', 'Plot2', 'Plot3'];
  String? selectedPlot;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDB = FirebaseDatabase.instance.ref();

@override
  void initState() {
    super.initState();
    _loadSavedPlot();
  }

  Future<void> _loadSavedPlot() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPlot = prefs.getString('selected_plot');
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 170,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              fontSize: 16,
              color: Colors.blueGrey[800],
            ),
            items: plots.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green), 
                    SizedBox(width: 8),
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
