import 'package:soil_monitoring_app/models/sensor_log.dart';

List<SensorLog> generateLogs(
    Map<String, double> sensorReadings, Map<String, SensorLog?> lastLogs) {
  List<SensorLog> logs = [];

  sensorReadings.forEach((sensorId, value) {
    String description;
    String status;

    // Check if the value meets the conditions for generating a log
    if (value < 30) {
      description = 'Low reading detected';
      status = 'Abnormal';
    } else if (value > 70) {
      description = 'High reading detected';
      status = 'Abnormal';
    } else {
      description = 'Reading is normal';
      status = 'Normal';
    }

    var lastLog = lastLogs[sensorId];
    if (lastLog == null || _shouldCreateNewLog(lastLog, value)) {
      logs.add(SensorLog(
        startTimestamp: DateTime.now(),
        sensorId: sensorId,
        description: description,
        status: status,
      ));
    }
  });

  return logs;
}

// Helper function to determine if a new log is needed based on value change
bool _shouldCreateNewLog(SensorLog lastLog, double newValue) {
  // Check if the description or status has changed significantly
  if ((lastLog.status == 'Normal' && newValue < 30) ||
      (lastLog.status == 'Normal' && newValue > 70) ||
      (lastLog.status != 'Normal' && (newValue >= 30 && newValue <= 70))) {
    return true; // A significant change in status or value
  }
  return false;
}
