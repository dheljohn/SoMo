import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  void showWarningPopup(BuildContext context, String title, double value) {
    String message;
    Color textColor = Colors.black;

    if (value < 30) {
      message = 'Warning: Low moisture detected!';
      textColor = Colors.red;
    } else if (value > 70) {
      message = 'Warning: High moisture detected!';
      textColor = Colors.blue;
    } else {
      message = 'Moisture level is normal.';
      textColor = Colors.green;
    }

    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: TextStyle(fontSize: 16, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget buildGauge(BuildContext context, String title, double value, Color bgColor) {
    return GestureDetector(
      onTap: () => showWarningPopup(context, title, value),
      child: Container(
        height: 100,
        width: 165,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$value%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 60,
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        radiusFactor: 0.7,
                        showTicks: false,
                        showLabels: false,
                        minimum: 0,
                        maximum: 100,
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: value,
                            color: value < 30
                                ? Colors.yellow
                                : value > 70
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 81, 129, 77),
                            enableAnimation: true,
                            cornerStyle: CornerStyle.bothCurve,
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Function to get text color based on value and type
    Color getTextColor(String type, double value) {
      switch (type) {
        case 'humidity':
          return value < 30
              ? Colors.blue
              : value > 70
                  ? Colors.orange
                  : Colors.green;
        case 'temperature':
          return value < 15
              ? Colors.blue
              : value > 30
                  ? Colors.red
                  : Colors.green;
        case 'soilMoisture':
          return value < 30
              ? Colors.yellow
              : value > 70
                  ? Colors.blue
                  : Colors.green;
        default:
          return Colors.grey;
      }
    }

    return Column(
      children: [
        const SizedBox(height: 5),

        // First Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildGauge(context, 'Soil Moisture S1', dataProvider.moistureS1,
                const Color.fromARGB(255, 191, 224, 198)),
            buildGauge(context, 'Soil Moisture S2', dataProvider.moistureS2,
                const Color.fromARGB(255, 235, 231, 208)),
          ],
        ),

        // Second Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildGauge(context, 'Soil Moisture S3', dataProvider.moistureS3,
                const Color.fromARGB(255, 253, 252, 245)),
            buildGauge(context, 'Soil Moisture S4', dataProvider.moistureS4,
                Colors.orange.shade50),
          ],
        ),

        const SizedBox(height: 20),

        // Humidity, Temperature, and Soil Moisture Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text(
                  'Humidity:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${dataProvider.humidityValue}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getTextColor('humidity', dataProvider.humidityValue),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Temperature:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${dataProvider.temperatureValue}°C',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(
                        'temperature', dataProvider.temperatureValue),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  'Soil Moisture:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${dataProvider.moistureA}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getTextColor('soilMoisture', dataProvider.moistureA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
