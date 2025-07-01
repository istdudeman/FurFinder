class PetStatus {
  final String petName;
  final String deviceId;
  final DateTime lastSeen;
  final String? activity;
  final String? activityTime;

  PetStatus({
    required this.petName,
    required this.deviceId,
    required this.lastSeen,
    this.activity,
    this.activityTime,
  });

  factory PetStatus.fromJson(Map<String, dynamic> json) {
    return PetStatus(
      petName: json['pet_name'],
      deviceId: json['device_id'],
      lastSeen: DateTime.parse(json['timestamp']),
      activity: json['description'],
      activityTime: json['time_log'],
    );
  }
}
