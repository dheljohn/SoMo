import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatefulWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  @override
  _GaugesState createState() => _GaugesState();
}

class _GaugesState extends State<Gauges> {
  Map<String, bool> showWarning = {
    'Soil Moisture S1': false,
    'Soil Moisture S2': false,
    'Soil Moisture S3': false,
    'Soil Moisture S4': false,
  };

  String getWarningMessage(double value) {
    if (value < 30) {
      return 'Low Moisture!';
    } else if (value > 70) {
      return 'High Moisture!';
    } else {
      return 'Moisture Level Normal';
    }
  }

  Color getWarningColor(double value) {
    if (value < 30) {
      return Colors.red;
    } else if (value > 70) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  Widget buildGauge(BuildContext context, String title, double value, Color bgColor) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showWarning[title] = !showWarning[title]!;
        });
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: showWarning[title]!
            ? Container(
                key: ValueKey('$title-warning'),
                height: 100,
                width: 165,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 42, 83, 39)),
                  color: getWarningColor(value).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    getWarningMessage(value),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: getWarningColor(value),
                    ),
                  ),
                ),
              )
            : Container(
                key: ValueKey('$title-gauge'),
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
            buildGauge(context, 'Soil Moisture S1', widget.dataProvider.moistureS1,
                const Color.fromARGB(255, 191, 224, 198)),
            buildGauge(context, 'Soil Moisture S2', widget.dataProvider.moistureS2,
                const Color.fromARGB(255, 235, 231, 208)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildGauge(context, 'Soil Moisture S3', widget.dataProvider.moistureS3,
                const Color.fromARGB(255, 253, 252, 245)),
            buildGauge(context, 'Soil Moisture S4', widget.dataProvider.moistureS4,
                Colors.orange.shade50),
          ],
        ),
      ],
    );
  }
}
