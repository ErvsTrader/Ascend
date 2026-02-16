import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../models/habit.dart';

// ---------------------------------------------------------------------------
// NotificationService – handles scheduling daily reminders
// ---------------------------------------------------------------------------

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Initialize notifications and timezone data.
  Future<void> init() async {
    // Initialize timezone data
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payload) {
        // Handle notification tap – for now, just open the app
        debugPrint('Notification tapped: ${payload.payload}');
      },
    );
  }

  /// Explicitly request permissions.
  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlatformChannelSpecifics =
          _plugin.resolvePlatformSpecifics<AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlatformChannelSpecifics?.requestNotificationsPermission() ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
              .resolvePlatformSpecifics<IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }
    return false;
  }

  /// Schedule a daily reminder for a specific habit.
  Future<void> scheduleHabitReminder(Habit habit) async {
    final int id = habit.id.hashCode;
    
    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.reminderHour,
      habit.reminderMinute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      'Time for ${habit.name}! 💪',
      'Keep your streak going! Tap to check in.',
      scheduledDate,
      _notificationDetails(habit.color),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: habit.id,
    );
    
    debugPrint('Scheduled reminder for "${habit.name}" at ${habit.reminderHour}:${habit.reminderMinute}');
  }

  /// Cancel a scheduled reminder.
  Future<void> cancelHabitReminder(String habitId) async {
    await _plugin.cancel(habitId.hashCode);
    debugPrint('Cancelled reminder for habit ID: $habitId');
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _notificationDetails(Color color) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'habit_reminders',
        'Habit Reminders',
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.max,
        priority: Priority.high,
        color: color,
        ledColor: color,
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
