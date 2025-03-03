import 'package:firebase_database/firebase_database.dart';
// Import ChartData

void fetchDataFromFirebase({
  required Function(double) updateHumidity,
  required Function(double) updateTemperature,
  required Function(double) updateMoistureAverage,
  required Function(int, int, int, int) updateMoistureData,
}) {
  DatabaseReference humidityRef =
      FirebaseDatabase.instance.ref().child('Humidity/humidity');
  DatabaseReference temperatureRef =
      FirebaseDatabase.instance.ref().child('Temperature/temperature');
  DatabaseReference moistureAvgRef =
      FirebaseDatabase.instance.ref().child('Moisture/Average');
  DatabaseReference moistureDataRef =
      FirebaseDatabase.instance.ref().child('Moisture');

  // Fetch Humidity
  humidityRef.once().then((event) {
    double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
    updateHumidity(value);
  });

  // Fetch Temperature
  temperatureRef.once().then((event) {
    double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
    updateTemperature(value);
  });

  // Fetch Moisture Average
  moistureAvgRef.once().then((event) {
    double value = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
    updateMoistureAverage(value);
  });

  // Fetch Moisture Data and Update Chart
  moistureDataRef.once().then((event) {
    final value = event.snapshot.value as Map<dynamic, dynamic>?;
    if (value != null) {
      final timestamp = DateTime.now();
      final moisture1 =
          int.tryParse(value['MoistureReadings_1'].toString()) ?? 0;
      final moisture2 =
          int.tryParse(value['MoistureReadings_2'].toString()) ?? 0;
      final moisture3 =
          int.tryParse(value['MoistureReadings_3'].toString()) ?? 0;
      final moisture4 =
          int.tryParse(value['MoistureReadings_4'].toString()) ?? 0;

      updateMoistureData(moisture1, moisture2, moisture3, moisture4);
    }
  });
}
