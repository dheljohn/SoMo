import 'package:flutter/material.dart';

class DataProvider extends InheritedWidget {
  final double humidityValue;
  final double temperatureValue;
  final double moistureA;
  final double moistureS1;
  final double moistureS2;
  final double moistureS3;
  final double moistureS4;

  const DataProvider({
    super.key,
    required this.humidityValue,
    required this.temperatureValue,
    required this.moistureA,
    required this.moistureS1,
    required this.moistureS2,
    required this.moistureS3,
    required this.moistureS4,
    required super.child,
  });

  static DataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataProvider>();
  }

  @override
  bool updateShouldNotify(DataProvider oldWidget) {
    return oldWidget.humidityValue != humidityValue ||
        oldWidget.temperatureValue != temperatureValue ||
        oldWidget.moistureA != moistureA ||
        oldWidget.moistureS1 != moistureS1 ||
        oldWidget.moistureS2 != moistureS2 ||
        oldWidget.moistureS3 != moistureS3 ||
        oldWidget.moistureS4 != moistureS4;
  }
}
