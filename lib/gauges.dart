import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  Widget buildGauge(String title, double value, Color bgColor) {
    return Container(
      height: 110,
      width: 60,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromARGB(255, 42, 83, 39),
        ),
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.shade300,
        //     blurRadius: 5,
        //     offset: const Offset(0, 3),
        //   ),
        // ],
      ),
      child: Row(
        children: [
          // Percentage and Title Section
          Flexible(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$value%",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Radial Gauge
          Flexible(
            flex: 1,
            child: Container(
              height: 80,
              width: 80,
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
          ),
        ],
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
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: buildGauge('Soil Moisture S1', dataProvider.moistureS1,
                  const Color.fromARGB(255, 191, 224, 198)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildGauge('Soil Moisture S2', dataProvider.moistureS2,
                  const Color.fromARGB(255, 235, 231, 208)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: buildGauge('Soil Moisture S3', dataProvider.moistureS3,
                  const Color.fromARGB(255, 253, 252, 245)),
            ),
            const SizedBox(width: 1),
            Expanded(
              child: buildGauge('Soil Moisture S4', dataProvider.moistureS4,
                  Colors.orange.shade50),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Humidity
            Column(
              children: [
                Text(
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
            // Temperature
            Column(
              children: [
                Text(
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
            // Soil Moisture
            Column(
              children: [
                Text(
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
