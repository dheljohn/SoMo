import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  String getWarningMessage(double value) {
    if (value <= 5) {
      return 'Sensor not deployed';
    } else if (value <= 29) {
      return 'Extremely Dry Soil!';
    } else if (value < 46) {
      return 'Well Drained Soil!';
    } else if (value <= 75) {
      return 'Moist Soil';
    } else {
      return 'Wet Soil';
    }
  }

  String getRecommendationMessage(double value) {
    if (value <= 5) {
      return 'Sensor not deployed';
    } else if (value <= 29) {
      return ' Extremely Dry Soil Detected! \nRecommendation: Water the soil as needed. 🌱';
    } else if (value <= 46) {
      return 'Well Drained Soil!\nRecommendation: Considering watering soon.🌱';
    } else if (value <= 75) {
      return 'Moist Soil. \nIdeal Moisture Level. 🌱';
    } else {
      return 'Wet Soil Detected! \nRecommendation: Turn Off the Drip line or Skip the next scheduled watering and improve soil drainage. 🚰';
    }
  }

  Color getWarningColor(double value) {
    if (value <= 5) {
      return Colors.grey;
    } else if (value == 15 || value <= 29) {
      return const Color.fromARGB(255, 253, 133, 124);
    } else if (value == 30 || value < 46) {
      return const Color.fromARGB(255, 236, 188, 66);
    } else if (value == 46 || value <= 75) {
      return const Color.fromARGB(255, 103, 172, 105);
    } else if (value > 75) {
      return const Color.fromARGB(255, 131, 174, 209);
    } else {
      return Colors.green;
    }
  }

  void showSensorModal(BuildContext context, String title, double value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            // decoration: BoxDecoration(
            //   border: Border.all(color: Color.fromARGB(255, 42, 83, 39), width: 4),
            //   borderRadius: BorderRadius.circular(10),
            // ),
            padding: EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: getWarningColor(value),
                border: Border.all(
                    color: Color.fromARGB(255, 242, 239, 231), width: 4),
                borderRadius: BorderRadius.circular(6),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 253, 253, 253),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    getRecommendationMessage(value),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () => Navigator.pop(context),
                  //     child: const Text('Close', style: TextStyle(color: Colors.white)),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildGauge(
      BuildContext context, String title, double value, Color bgColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gaugeSize = screenWidth / 3; // Adjust the divisor to change the size
    final gaugeHeight =
        gaugeSize / 1.2; // Adjust the divisor to change the height

    return GestureDetector(
      onTap: () => showSensorModal(context, title, value),
      child: Container(
        height: gaugeHeight,
        width: gaugeSize,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 42, 83, 39)),
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value > 5 ? "${value.toInt()}%" : "0%",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: gaugeSize / 2.9,
                  width: gaugeSize / 2.9,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        radiusFactor: 0.9,
                        showTicks: false,
                        showLabels: false,
                        minimum: 0,
                        maximum: 100,
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: value >= 5
                                ? value
                                : 0, // Show 0% if not deployed
                            color: getWarningColor(value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              getWarningMessage(value),
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
                color: getWarningColor(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildGauge(context, 'Soil Moisture S1',
                    dataProvider.moistureS1, Colors.orange.shade50),
              ),
              Expanded(
                child: buildGauge(context, 'Soil Moisture S2',
                    dataProvider.moistureS2, Colors.orange.shade50),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildGauge(context, 'Soil Moisture S3',
                    dataProvider.moistureS3, Colors.orange.shade50),
              ),
              Expanded(
                child: buildGauge(context, 'Soil Moisture S4',
                    dataProvider.moistureS4, Colors.orange.shade50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
