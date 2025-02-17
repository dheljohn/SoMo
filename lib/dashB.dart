import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:soil_monitoring_app/gauges.dart'; // Import the new file
import 'package:soil_monitoring_app/helpmsg.dart';

class DashB extends StatefulWidget {
  const DashB({super.key});

  @override
  State<DashB> createState() => _DashBState();
}

class _DashBState extends State<DashB> {
  final Future<FirebaseApp> _fApp = Firebase.initializeApp();

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Center(
              // child: Container(
              //   margin: EdgeInsets.all(5),
              //   height: MediaQuery.of(context).size.height * 0.1,
              //   child: Image.asset('lib/assets/images/image.png'),
              // ),
              ),
          const SizedBox(height: 120),
          Gauges(dataProvider: dataProvider), // Use the Gauges widget
          const SizedBox(height: 15),

          SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                const SizedBox(width: 30),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  height: MediaQuery.of(context).size.height * 0.1,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/somo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    color: const Color.fromARGB(255, 247, 246, 237),
                    margin: const EdgeInsets.all(5),
                    height: 150,
                    width: 300,
                    child: const Row(
                      children: [
                        Expanded(child: HelperMsg()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(width: 10),


          /* eto yung image na may interpretation ng values 
          Center(
            child: Container(
              margin: EdgeInsets.all(5),
              height: MediaQuery.of(context).size.height * 0.1,
              child: Image.asset('lib/assets/images/image.png'),
            ),
          ),
          Gauges(dataProvider: dataProvider), // Use the Gauges widget
          SizedBox(height: 10),
          */

          // Container(
          //   color: Colors.red,
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height * 0.2,
          //     child: Row(),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// class ChartData {
//   final DateTime time;
//   final double value;

//   ChartData(this.time, this.value);
// }