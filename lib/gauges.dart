import 'package:flutter/material.dart';
import 'package:soil_monitoring_app/data_provider.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Gauges extends StatelessWidget {
  final DataProvider dataProvider;

  const Gauges({required this.dataProvider, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         SizedBox(height: 50,),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150,
                child: SfRadialGauge(
                  title: const GaugeTitle(
                      text: 'Soil Moisture S1',
                      textStyle: TextStyle(fontSize: 15)),
                  axes: <RadialAxis>[
                    RadialAxis(
                      showTicks: false,
                      showLabels: false,
                      minimum: 0,
                      maximum: 100,
                      interval: 10,
                      pointers: <GaugePointer>[
                        RangePointer(
                            value: dataProvider.moistureS1,
                            color: Colors.blue,
                            enableAnimation: true,
                            cornerStyle: gauges.CornerStyle.bothCurve),
                        if (dataProvider.moistureS1 < 30)
                          RangePointer(
                              value: dataProvider.moistureS1,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else if (dataProvider.moistureS1 > 70)
                          RangePointer(
                              value: dataProvider.moistureS1,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else
                          RangePointer(
                              value: dataProvider.moistureS1,
                              color: Colors.green,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            "${dataProvider.moistureS1}%",
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
              child: Container(
                height: 150,
                child: SfRadialGauge(
                  title: const GaugeTitle(
                      text: 'Soil Moisture S2',
                      textStyle: TextStyle(fontSize: 15)),
                  axes: <RadialAxis>[
                    RadialAxis(
                      showTicks: false,
                      showLabels: false,
                      minimum: 0,
                      maximum: 100,
                      interval: 10,
                      pointers: <GaugePointer>[
                        RangePointer(
                            value: dataProvider.moistureS2,
                            color: Colors.blue,
                            enableAnimation: true,
                            cornerStyle: gauges.CornerStyle.bothCurve),
                        if (dataProvider.moistureS2 < 30)
                          RangePointer(
                              value: dataProvider.moistureS2,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else if (dataProvider.moistureS2 > 70)
                          RangePointer(
                              value: dataProvider.moistureS2,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else
                          RangePointer(
                              value: dataProvider.moistureS2,
                              color: Colors.green,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            "${dataProvider.moistureS2}%",
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
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150,
                child: SfRadialGauge(
                  title: const GaugeTitle(
                      text: 'Soil Moisture S3',
                      textStyle: TextStyle(fontSize: 15)),
                  axes: <RadialAxis>[
                    RadialAxis(
                      showTicks: false,
                      showLabels: false,
                      minimum: 0,
                      maximum: 100,
                      interval: 10,
                      pointers: <GaugePointer>[
                        RangePointer(
                            value: dataProvider.moistureS3,
                            color: Colors.blue,
                            enableAnimation: true,
                            cornerStyle: gauges.CornerStyle.bothCurve),
                        if (dataProvider.moistureS3 < 30)
                          RangePointer(
                              value: dataProvider.moistureS3,
                              color: Colors.yellow,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else if (dataProvider.moistureS3 > 70)
                          RangePointer(
                              value: dataProvider.moistureS3,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else
                          RangePointer(
                              value: dataProvider.moistureS3,
                              color: Colors.green,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            "${dataProvider.moistureS3}%",
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
              child: Container(
                height: 150,
                child: SfRadialGauge(
                  title: const GaugeTitle(
                      text: 'Soil Moisture S4',
                      textStyle: TextStyle(fontSize: 15)),
                  axes: <RadialAxis>[
                    RadialAxis(
                      showTicks: false,
                      showLabels: false,
                      minimum: 0,
                      maximum: 100,
                      interval: 10,
                      pointers: <GaugePointer>[
                        RangePointer(
                            value: dataProvider.moistureS4,
                            color: Colors.blue,
                            enableAnimation: true,
                            cornerStyle: gauges.CornerStyle.bothCurve),
                        if (dataProvider.moistureS4 < 30)
                          RangePointer(
                              value: dataProvider.moistureS4,
                              color: Colors.yellow,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else if (dataProvider.moistureS4 > 70)
                          RangePointer(
                              value: dataProvider.moistureS4,
                              color: Colors.blue,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve)
                        else
                          RangePointer(
                              value: dataProvider.moistureS4,
                              color: Colors.green,
                              enableAnimation: true,
                              cornerStyle: gauges.CornerStyle.bothCurve),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text(
                            "${dataProvider.moistureS4}%",
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
        ),

        SizedBox(height: 20,),
        
       Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
  children: [
    Container(
      height: 70,
      width: 110, 
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Humidity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${dataProvider.humidityValue}%',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ],
      ),
    ),
    SizedBox(width: 10), 
    Container(
      height: 70,
      width: 110, 
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Temperature',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${dataProvider.temperatureValue}°C',
            style: TextStyle(fontSize: 18, color: Colors.orange),
          ),
        ],
      ),
    ),
    SizedBox(width: 10), 
    Container(
      height: 70,
      width: 110, 
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Soil Moisture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            '${dataProvider.moistureA}%',
            style: TextStyle(fontSize: 18, color: Colors.green),
          ),
        ],
      ),
    ),
  ],
),


      ],
    );
  }
}
