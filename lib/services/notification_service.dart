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
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = tzInfo.identifier;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

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
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      
      // Also request exact alarm permission if needed (Android 13+)
      await androidImplementation?.requestExactAlarmsPermission();
      
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await iosImplementation?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
    }
    return false;
  }

  /// Schedule a daily reminder for a specific habit.
  Future<void> scheduleHabitReminder(Habit habit, {String? sound}) async {
    if (habit.reminderHour == null || habit.reminderMinute == null) return;

    // Android requires notification IDs to be 32-bit integers.
    // Use a signed 31-bit hash to stay well within the safe range.
    final int id = habit.id.hashCode & 0x7FFFFFFF;
    
    // Calculate next occurrence
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      habit.reminderHour!,
      habit.reminderMinute!,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        'Time for ${habit.name}! 💪',
        'Keep your streak going! Tap to check in.',
        scheduledDate,
        _notificationDetails(habit.color, sound: sound),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: habit.id,
      );
      debugPrint('Scheduled EXACT reminder for "${habit.name}" at ${habit.reminderHour}:${habit.reminderMinute} with sound: ${sound ?? "default"}');
    } catch (e) {
      if (e.toString().contains('exact_alarms_not_permitted')) {
        debugPrint('Exact alarms not permitted. Falling back to inexact.');
        await _plugin.zonedSchedule(
          id,
          'Time for ${habit.name}! 💪',
          'Keep your streak going! Tap to check in.',
          scheduledDate,
          _notificationDetails(habit.color, sound: sound),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: habit.id,
        );
      } else {
        rethrow;
      }
    }
  }

  /// Cancel a scheduled reminder.
  Future<void> cancelHabitReminder(String habitId) async {
    await _plugin.cancel(habitId.hashCode & 0x7FFFFFFF);
    debugPrint('Cancelled reminder for habit ID: $habitId');
  }

  /// Cancel all scheduled notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  NotificationDetails _notificationDetails(Color color, {String? sound}) {
    final String channelId = sound != null && sound != 'default' ? 'habit_reminders_$sound' : 'habit_reminders';
    final String channelName = sound != null && sound != 'default' ? 'Habit Reminders ($sound)' : 'Habit Reminders';

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Daily reminders for your habits',
        importance: Importance.max,
        priority: Priority.high,
        color: color,
        ledColor: color,
        ledOnMs: 1000,
        ledOffMs: 500,
        sound: sound != null && sound != 'default' ? RawResourceAndroidNotificationSound(sound) : null,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: sound != null && sound != 'default' ? '$sound.aiff' : null,
      ),
    );
  }
}
