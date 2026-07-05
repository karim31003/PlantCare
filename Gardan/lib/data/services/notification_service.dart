import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  // ─── Initialize ───────────────────────────────────────────────────

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
   const windows = WindowsInitializationSettings(
  appName: 'Gardain',
  appUserModelId: 'com.gardain.app',
  guid: 'd49b0314-ee7a-4b86-b8f9-1f6dfc2f1a11',
);

const settings = InitializationSettings(
  android: android,
  windows: windows,
);

await _plugin.initialize(settings: settings);


    // Request permission on Android 13+
   final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
await androidPlugin?.requestNotificationsPermission();
  }

  // ─── Schedule a watering reminder ────────────────────────────────

  static Future<void> scheduleReminder({
    required int id,
    required String plantName,
    required String scheduledTime, // format: "HH:mm"
    required String frequency,     // "daily" or "every_X_days"
  }) async {
    final parts = scheduledTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
  id: id,
  title: '💧 Time to water!',
  body: 'Your plant "$plantName" needs watering.',
  scheduledDate: scheduled,
  notificationDetails: const NotificationDetails(
    android: AndroidNotificationDetails(
      'watering_reminders',
      'Watering Reminders',
      channelDescription: 'Reminders to water your plants',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    ),
  ),
  matchDateTimeComponents: frequency == 'daily'
      ? DateTimeComponents.time
      : DateTimeComponents.dayOfWeekAndTime,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
);
}

  // ─── Cancel a reminder ────────────────────────────────────────────

  static Future<void> cancelReminder(int id) async {
await _plugin.cancel(id: id);
  }

  // ─── Cancel all reminders ─────────────────────────────────────────

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }
}