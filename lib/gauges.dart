import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  String getWarningMessage(double value) {
    if (value <= 5) {
      return 'Sensor not deployed';
    } else if (value == 15 || value <= 30) {
      return 'Extremely Dry Soil!';
    } else if (value == 30 || value < 45) {
      return 'Well Drained Soil!';
    } else if (value == 45 || value <= 75) {
      return 'Moist Soil';
    } else if (value > 75) {
      return 'Wet Soil';
    } else {
      return '';
    }
  }

  Color getWarningColor(double value) {
    if (value <= 5) {
      return Colors.grey;
    } else if (value == 15 || value <= 30) {
      return const Color.fromARGB(255, 253, 133, 124);
    } else if (value == 30 || value < 45) {
      return const Color.fromARGB(255, 236, 188, 66);
    } else if (value == 45 || value <= 75) {
      return const Color.fromARGB(255, 103, 172, 105);
    } else if (value > 75) {
      return const Color.fromARGB(255, 131, 174, 209);
    } else {
      return Colors.green;
    }
  }

  Widget buildGauge(
      BuildContext context, String title, double value, Color bgColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gaugeSize = screenWidth / 3; // Adjust the divisor to change the size
    final gaugeHeight =
        gaugeSize / 1.2; // Adjust the divisor to change the height

    return Container(
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
                "${value.toInt()}%",
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
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
                          value: value,
                          color: value < 30 && value >= 15
                              ? const Color.fromARGB(255, 253, 133, 124)
                              : value < 45
                                  ? const Color.fromARGB(255, 236, 188, 66)
                                  : value > 70
                                      ? const Color.fromARGB(255, 131, 174, 209)
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
                child: buildGauge(
                    context,
                    'Soil Moisture S1',
                    dataProvider.moistureS1,
                    const Color.fromARGB(255, 191, 224, 198)),
              ),
              Expanded(
                child: buildGauge(
                    context,
                    'Soil Moisture S2',
                    dataProvider.moistureS2,
                    const Color.fromARGB(255, 235, 231, 208)),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: buildGauge(
                    context,
                    'Soil Moisture S3',
                    dataProvider.moistureS3,
                    const Color.fromARGB(255, 253, 252, 245)),
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
