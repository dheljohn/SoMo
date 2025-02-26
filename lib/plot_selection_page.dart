import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PlotSelection extends StatefulWidget {
  @override
  _PlotSelectionState createState() => _PlotSelectionState();
}

class _PlotSelectionState extends State<PlotSelection> {
  final List<String> plots = ['Plot1', 'Plot2', 'Plot3'];
  String? selectedPlot;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDB = FirebaseDatabase.instance.ref();

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
                value: selectedPlot, // Handle null value
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
                    _savePlotToFirebase(
                        newValue); // Use the function for consistency
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
  
  // The  _savePlotToFirebase  function saves the selected plot to both Firestore and Realtime Database. The Firestore collection is named  selected_plots  and the document is named  currentPlot . The Realtime Database key is  SelectedPlot . 
  // The  DropdownButton  widget is used to display the list of plots. When a plot is selected, the  onChanged  callback is triggered. The selected plot is saved to Firebase and the UI is updated. 
  // Step 4: Display the selected plot
  // To display the selected plot, we will create a new page named  PlotDisplay . This page will listen to changes in the Realtime Database and update the UI accordingly. 
  // Create a new file named  plot_display_page.dart  and add the following code: