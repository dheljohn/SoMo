import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soil_monitoring_app/switch_button.dart' show SwitchButton;
import 'package:provider/provider.dart';
import 'package:soil_monitoring_app/language_provider.dart';
import 'package:soil_monitoring_app/tts_provider.dart';

class PlotSelection extends StatefulWidget {
  final Function(String) onPlotChanged; // Notify parent when selection changes

  const PlotSelection({required this.onPlotChanged, Key? key})
      : super(key: key);
  @override
  _PlotSelectionState createState() => _PlotSelectionState();
}

class _PlotSelectionState extends State<PlotSelection> {
  final List<String> plots = ['Lettuce', 'Pechay', 'Mustard'];
  String? selectedPlot = 'Lettuce';
  bool showRecommendation = false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseReference realtimeDB = FirebaseDatabase.instance.ref();

  final Map<String, Map<String, String>> cropDetails = {
    'Lettuce': {
      'moisture': '60-80%',
      'watering': 'Daily in the morning',
      'soil': 'Well-draining loamy soil',
    },
    'Pechay': {
      'moisture': '50-70%',
      'watering': 'Twice a day',
      'soil': 'Sandy loam with organic matter',
    },
    'Mustard': {
      'moisture': '40-60%',
      'watering': 'Every other day',
      'soil': 'Loamy soil with good drainage',
    },
  };

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
    print("Selected plot saved to Firebase: $plot");
  }

  String translateDetail(String key, String value, bool isFilipino) {
    if (!isFilipino) return value;
    final translations = {
      'Soil Moisture': 'Halumigmig ng Lupa',
      'Watering Schedule': 'Iskedyul ng Pag-didilig',
      'Soil Type': 'Uri ng Lupa',
      'Daily in the morning': 'Tuwing umaga',
      'Twice a day': 'Dalawang beses sa isang araw',
      'Every other day': 'Tuwing ikalawang araw',
      'Well-draining loamy soil': 'Lupang may maayos na drainage',
      'Sandy loam with organic matter':
          'Mabuhanging lupa na may organikong materyal',
      'Loamy soil with good drainage':
          'Lupang mabuhaghag na may magandang drainage',
    };
    return translations[value] ?? value;
  }

  @override
  Widget build(BuildContext context) {
    String translatePlotName(String plot, bool isFilipino) {
      if (!isFilipino) return plot;
      return {
            'Lettuce': 'Litsugas',
            'Pechay': 'Petsay',
            'Mustard': 'Mustasa',
          }[plot] ??
          plot;
    }

    bool isFilipino = context.watch<LanguageProvider>().isFilipino;

    MediaQueryData queryData = MediaQuery.of(context);
    double screenWidth = queryData.size.width;
    bool isSpeaking = context.watch<TtsProvider>().isSpeaking;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures spacing
          children: [
            Container(
              width: screenWidth * 0.72,
              height: screenWidth * 0.15,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 139, 169, 130),
                border: Border.all(color: Colors.blueGrey, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        alignment: Alignment
                            .centerLeft, // Keeps dropdown in one position
                        menuMaxHeight: 160, // Limits dropdown height
                        value: selectedPlot,
                        dropdownColor: const Color.fromARGB(255, 139, 169, 130),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          color: isSpeaking
                              ? Colors.grey
                              : Color.fromARGB(255, 249, 249, 249),
                        ),
                        items: plots.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(Icons.eco,
                                    color: const Color.fromARGB(
                                        255, 246, 250, 246),
                                    size: screenWidth * 0.05),
                                SizedBox(width: 4),
                                Text(translatePlotName(value, isFilipino)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: isSpeaking
                            ? null
                            : (newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedPlot = newValue;
                                  });
                                  _savePlot(newValue);
                                  widget
                                      .onPlotChanged(newValue); // Notify parent
                                }
                              },
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showRecommendation = !showRecommendation;
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                          isFilipino ? "Rekomendasyon" : "Recommendation",
                          style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: const Color.fromARGB(255, 255, 255, 255)),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          showRecommendation
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 25,
                          color: const Color.fromARGB(255, 232, 234, 232),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Switch button moved outside and aligned to the right
            SwitchButton(),
          ],
        ),

        SizedBox(height: 8),

        // Hide the container when recommendation is not shown
        if (showRecommendation)
          Container(
            width: screenWidth * 0.9,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 249, 242, 211),
              border: Border.all(color: Colors.blueGrey, width: 1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFilipino
                      ? "Inirerekomenda para sa ${translatePlotName(selectedPlot!, isFilipino)}"
                      : "Recommended for ${selectedPlot}",
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 1),
                Text(
                  "${translateDetail('Soil Moisture', 'Soil Moisture', isFilipino)}: ${translateDetail('Soil Moisture', cropDetails[selectedPlot]?['moisture'] ?? 'N/A', isFilipino)}",
                ),
                Text(
                  "${translateDetail('Watering Schedule', 'Watering Schedule', isFilipino)}: ${translateDetail('Watering Schedule', cropDetails[selectedPlot]?['watering'] ?? 'N/A', isFilipino)}",
                ),
                Text(
                  "${translateDetail('Soil Type', 'Soil Type', isFilipino)}: ${translateDetail('Soil Type', cropDetails[selectedPlot]?['soil'] ?? 'N/A', isFilipino)}",
                ),
              ],
            ),
          ),
      ],
    );
  }
}
