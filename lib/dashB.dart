import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/gauges.dart';
import 'package:soil_monitoring_app/helpmsg.dart';

class DashB extends StatefulWidget {
  const DashB({super.key});

  @override
  State<DashB> createState() => _DashBState();
}

class _DashBState extends State<DashB> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();
  String? _weather;
  String? _location;

  @override
  void initState() {
    super.initState();
  }

  String _getFormattedDate() {
    return DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = DataProvider.of(context);
    if (dataProvider == null) {
      return const Text("DataProvider is null");
    }

    return FutureBuilder(
      future: _fApp,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong with firebase");
        } else if (snapshot.hasData) {
          return dashboardMain(dataProvider);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget dashboardMain(DataProvider dataProvider) {
    return Container(
      color: const Color.fromARGB(255, 247, 246, 237),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM d, yyyy').format(DateTime.now()), // Date
                    style: const TextStyle(
                      color: Color.fromARGB(255, 60, 90, 64),
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE').format(DateTime.now()), // Day
                    style: const TextStyle(
                      color: Color.fromARGB(255, 60, 90, 64),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 2),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blue),
            onPressed: () {
              _showSoilMoistureInfo(context);
            },
          ),
          Gauges(dataProvider: dataProvider),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: Container(
              color: const Color.fromARGB(255, 247, 246, 237),
              margin: const EdgeInsets.all(5),
              height: 170,
              width: double.infinity,
              child: const HelperMsg(),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoilMoistureInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              const Color.fromARGB(255, 242, 239, 231), // Light background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
                color: Color.fromARGB(255, 42, 83, 39),
                width: 2), // Green border
          ),
          title: const Center(
            child: Text(
              'Soil Moisture Levels',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 100, 122, 99),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '🌵 ', style: TextStyle(fontSize: 18)),
                    TextSpan(
                      text: '15%  ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text: '– Extremely Dry Soil',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 65, 64, 64))),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '🌾 ', style: TextStyle(fontSize: 18)),
                    TextSpan(
                      text: '30-45%  ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text: '– Dry / Well-Drained Soil',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 65, 64, 64))),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '🌱 ', style: TextStyle(fontSize: 18)),
                    TextSpan(
                      text: '60-75%  ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text: '– Moist Soil',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 65, 64, 64))),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '💧 ', style: TextStyle(fontSize: 18)),
                    TextSpan(
                      text: '90%  ',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                        text: '– Wet Soil',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 65, 64, 64))),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
