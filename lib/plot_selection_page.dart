import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PlotSelection extends StatefulWidget {
  @override
  _PlotSelectionState createState() => _PlotSelectionState();
}

class _PlotSelectionState extends State<PlotSelection> {
  final List<String> plots = ['Plot 1', 'Plot 2', 'Plot 3'];
  String? selectedPlot;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDB = FirebaseDatabase.instance.ref();

  void _savePlotToFirebase(String plot) async {
    // Save to Firestore (for history)
    await firestore.collection("selected_plots").doc("currentPlot").set({
      "plot": plot,
      "timestamp": FieldValue.serverTimestamp(),
    });

    // Save to Realtime Database (for live updates)
    await realtimeDB.child("SelectedPlot").set(plot);

    print("Plot selected: $plot");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Plot")), // ✅ Fix 1: Add Scaffold
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
                hint: const Text("Select Plot"),
                items: plots.map((String plot) {
                  return DropdownMenuItem<String>(
                    value: plot,
                    child: Text(plot),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPlot = newValue;
                    _savePlotToFirebase(selectedPlot!);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
