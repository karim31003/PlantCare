
class Reminder {
  final String id;
  final String userId;
  final String plantName;
  final String scheduledTime; // "HH:mm"
  final String frequency;     // "daily" or "every_X_days"
  final bool isActive;
  final DateTime? createdAt;

  Reminder({
    required this.id,
    required this.userId,
    required this.plantName,
    required this.scheduledTime,
    this.frequency = 'daily',
    this.isActive = true,
    this.createdAt,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) => Reminder(
        id: map['id'],
        userId: map['user_id'],
        plantName: map['plant_name'],
        scheduledTime: map['scheduled_time'],
        frequency: map['frequency'] ?? 'daily',
        isActive: map['is_active'] ?? true,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'])
            : null,
      );

Map<String, dynamic> toMap() => {
  'user_id': userId,
  'plant_name': plantName,
  'scheduled_time': scheduledTime,
  'frequency': frequency,
  'is_active': isActive,
};
  Reminder copyWith({
    String? plantName,
    String? scheduledTime,
    String? frequency,
    bool? isActive,
  }) =>
      Reminder(
        id: id,
        userId: userId,
        plantName: plantName ?? this.plantName,
        scheduledTime: scheduledTime ?? this.scheduledTime,
        frequency: frequency ?? this.frequency,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt,
      );
}