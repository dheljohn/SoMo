import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  String getWarningMessage(double value) {
  if (value <= 5) {
    return 'No Deploy Sensor';
  } else if (value < 30) {
    return 'Extremely Dry Soil!';
  } else if (value > 45) {
    return 'Well Drained Soil!';
  } else if (value > 75) {
    return 'Moist Soil';
  } else if (value > 90) {
    return 'Wet Soil';
  } else {
    return 'Moisture Level Normal';
  }
}

Color getWarningColor(double value) {
  if (value <= 5) {
    return Colors.grey;
  } else if (value < 30) {
    return const Color.fromARGB(255, 253, 133, 124);
  } else if (value > 45) {
    return const Color.fromARGB(255, 236, 188, 66);
  } else if (value > 75) {
    return const Color.fromARGB(255, 103, 172, 105);
  } else if (value < 90) {
    return const Color.fromARGB(255, 131, 174, 209);
  } else {
    return Colors.green;
  }
}


  Widget buildGauge(BuildContext context, String title, double value, Color bgColor) {
    return Container(
      height: 120,
      width: 160,
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            getWarningMessage(value),
            style: TextStyle(
              fontSize: 12,
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
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildGauge(context, 'Soil Moisture S1', dataProvider.moistureS1,
                const Color.fromARGB(255, 191, 224, 198)),
            buildGauge(context, 'Soil Moisture S2', dataProvider.moistureS2,
                const Color.fromARGB(255, 235, 231, 208)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildGauge(context, 'Soil Moisture S3', dataProvider.moistureS3,
                const Color.fromARGB(255, 253, 252, 245)),
            buildGauge(context, 'Soil Moisture S4', dataProvider.moistureS4,
                Colors.orange.shade50),
          ],
        ),
      ],
    );
  }
}
