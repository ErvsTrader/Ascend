import 'package:flutter/foundation.dart';

import '../models/habit.dart';

// ---------------------------------------------------------------------------
// NotificationService (Web Stub) – no-op implementation for web platform
// ---------------------------------------------------------------------------

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // No-op on web
    debugPrint('NotificationService.init() - Web platform (no-op)');
  }

  Future<bool> requestPermissions() async {
    // No permissions needed on web
    return true;
  }

  Future<void> scheduleHabitReminder(Habit habit) async {
    // No-op on web
    debugPrint('NotificationService.scheduleHabitReminder() - Web platform (no-op)');
  }

  Future<void> cancelHabitReminder(String habitId) async {
    // No-op on web
  }

  Future<void> cancelAll() async {
    // No-op on web
  }
}
