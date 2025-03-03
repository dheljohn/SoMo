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
    // Save to Firestore (for historical logs)
    await firestore.collection("selected_plots").doc("currentPlot").set({
      "plot": plot,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Save to Realtime Database (for live updates)
    await realtimeDB.child("SelectedPlot").set({"plotName": plot});

    print("Plot selected: $plot");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Plot")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Choose a plot:", style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              DropdownButton<String>(
 value: selectedPlot,
                hint: Text("Select a plot"),
                items: plots.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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
              SizedBox(height: 20),
              Text(
                selectedPlot != null ? "Selected Plot: $selectedPlot" : "No plot selected",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
