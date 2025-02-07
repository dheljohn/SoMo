import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:soil_monitoring_app/data_provider.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 150,
            child: SfRadialGauge(
              title: const GaugeTitle(text: 'Humidity'),
              axes: <RadialAxis>[
                RadialAxis(
                  showTicks: false,
                  showLabels: false,
                  minimum: 0,
                  maximum: 100,
                  interval: 10,
                  pointers: <GaugePointer>[
                    RangePointer(
                        value: dataProvider.humidityValue,
                        color: Colors.blue,
                        enableAnimation: true,
                        cornerStyle: gauges.CornerStyle.bothCurve),
                    if (dataProvider.humidityValue < 40)
                      RangePointer(
                          value: dataProvider.humidityValue,
                          color: Colors.orange,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else if (dataProvider.humidityValue > 70)
                      RangePointer(
                          value: dataProvider.humidityValue,
                          color: Colors.blue,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else
                      RangePointer(
                          value: dataProvider.humidityValue,
                          color: Colors.green,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${dataProvider.humidityValue}%",
                        style: const TextStyle(fontSize: 20),
                      ),
                      positionFactor: 0.0,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 150,
            child: SfRadialGauge(
              title: const GaugeTitle(text: 'Temperature'),
              axes: <RadialAxis>[
                RadialAxis(
                  showTicks: false,
                  showLabels: false,
                  minimum: -30,
                  maximum: 60,
                  interval: 10,
                  pointers: <GaugePointer>[
                    RangePointer(
                        value: dataProvider.temperatureValue,
                        color: Colors.blue,
                        enableAnimation: true,
                        cornerStyle: gauges.CornerStyle.bothCurve),
                    if (dataProvider.temperatureValue < 20)
                      RangePointer(
                          value: dataProvider.temperatureValue,
                          color: Colors.blue,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else if (dataProvider.temperatureValue > 30)
                      RangePointer(
                          value: dataProvider.temperatureValue,
                          color: Colors.orange,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else
                      RangePointer(
                          value: dataProvider.temperatureValue,
                          color: Colors.green,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${dataProvider.temperatureValue}°C",
                        style: const TextStyle(fontSize: 20),
                      ),
                      positionFactor: 0.0,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 150,
            child: SfRadialGauge(
              title: const GaugeTitle(
                  text: 'Average Moisture', textStyle: TextStyle(fontSize: 15)),
              axes: <RadialAxis>[
                RadialAxis(
                  showTicks: false,
                  showLabels: false,
                  minimum: 0,
                  maximum: 100,
                  interval: 10,
                  pointers: <GaugePointer>[
                    RangePointer(
                        value: dataProvider.moistureA,
                        color: Colors.blue,
                        enableAnimation: true,
                        cornerStyle: gauges.CornerStyle.bothCurve),
                    if (dataProvider.moistureA < 30)
                      RangePointer(
                          value: dataProvider.moistureA,
                          color: Colors.blue,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else if (dataProvider.moistureA > 70)
                      RangePointer(
                          value: dataProvider.moistureA,
                          color: Colors.orange,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve)
                    else
                      RangePointer(
                          value: dataProvider.moistureA,
                          color: Colors.green,
                          enableAnimation: true,
                          cornerStyle: gauges.CornerStyle.bothCurve),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${dataProvider.moistureA}%",
                        style: const TextStyle(fontSize: 20),
                      ),
                      positionFactor: 0.0,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
