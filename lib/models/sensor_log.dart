class SensorLog {
  DateTime startTimestamp;
  DateTime? endTimestamp; // Make this nullable
  String sensorId;
  String description;
  String status;

  SensorLog({
    required this.startTimestamp,
    this.endTimestamp, // Default to null
    required this.sensorId,
    required this.description,
    required this.status,
  });

  get timestamp => null;

  // CopyWith method to create a new instance with updated fields
  SensorLog copyWith({DateTime? endTimestamp}) {
    return SensorLog(
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp ?? this.endTimestamp,
      sensorId: sensorId,
      description: description,
      status: status,
    );
  }

  // Convert log to CSV
  List<String> toCsv() {
    return [
      startTimestamp.toIso8601String(),
      sensorId,
      description,
      status,
    ];
  }
}
