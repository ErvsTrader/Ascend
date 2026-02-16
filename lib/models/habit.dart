import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'habit.g.dart';

/// Hive type ID for [Habit].
const int habitTypeId = 0;

// ---------------------------------------------------------------------------
// Habit model
// ---------------------------------------------------------------------------

@HiveType(typeId: habitTypeId)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  List<String> frequency;

  /// Stored as hour (0–23). Use [reminderTime] getter for `TimeOfDay`.
  @HiveField(5)
  int reminderHour;

  /// Stored as minute (0–59). Use [reminderTime] getter for `TimeOfDay`.
  @HiveField(6)
  int reminderMinute;

  @HiveField(7)
  List<DateTime> completedDates;

  @HiveField(8)
  final DateTime createdDate;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.colorValue,
    required this.frequency,
    required this.reminderHour,
    required this.reminderMinute,
    List<DateTime>? completedDates,
    DateTime? createdDate,
  })  : completedDates = completedDates ?? [],
        createdDate = createdDate ?? DateTime.now();

  // ── Convenience: TimeOfDay ──────────────────────────────────────────────

  /// The reminder as a Flutter [TimeOfDay].
  TimeOfDay get reminderTime => TimeOfDay(hour: reminderHour, minute: reminderMinute);

  set reminderTime(TimeOfDay time) {
    reminderHour = time.hour;
    reminderMinute = time.minute;
  }

  // ── Convenience: Color ──────────────────────────────────────────────────

  Color get color => Color(colorValue);
  set color(Color c) => colorValue = c.value;

  // ── Helper: normalise a DateTime to midnight ───────────────────────────

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ── Methods ────────────────────────────────────────────────────────────

  /// Whether the habit has been marked complete for today.
  bool isCompletedToday() {
    final today = _dateOnly(DateTime.now());
    return completedDates.any((d) => _dateOnly(d) == today);
  }

  /// Number of consecutive days completed ending at today (or the most
  /// recent completed date if today is not yet completed).
  int getCurrentStreak() {
    if (completedDates.isEmpty) return 0;

    // Unique sorted dates (newest → oldest).
    final sorted = completedDates
        .map(_dateOnly)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = _dateOnly(DateTime.now());

    // The streak must start from today or yesterday to be "current".
    if (sorted.first != today &&
        sorted.first != today.subtract(const Duration(days: 1))) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sorted.length - 1; i++) {
      final diff = sorted[i].difference(sorted[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  /// The longest consecutive-day streak ever recorded.
  int getBestStreak() {
    if (completedDates.isEmpty) return 0;

    final sorted = completedDates
        .map(_dateOnly)
        .toSet()
        .toList()
      ..sort();

    int best = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
      // diff == 0 means duplicate date → skip
    }
    return best;
  }

  /// Fraction of expected days on which the habit was completed,
  /// from [createdDate] through today (inclusive), considering [frequency].
  ///
  /// Returns 0.0 – 1.0.
  double getSuccessRate() {
    final today = _dateOnly(DateTime.now());
    final start = _dateOnly(createdDate);

    // Map weekday name → DateTime.weekday int (1 = Monday … 7 = Sunday).
    final weekdayMap = <String, int>{
      'Mon': DateTime.monday,
      'Tue': DateTime.tuesday,
      'Wed': DateTime.wednesday,
      'Thu': DateTime.thursday,
      'Fri': DateTime.friday,
      'Sat': DateTime.saturday,
      'Sun': DateTime.sunday,
    };

    final activeWeekdays = frequency
        .map((f) => weekdayMap[f])
        .whereType<int>()
        .toSet();

    // Count expected days.
    int expected = 0;
    for (var d = start;
        !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      if (activeWeekdays.contains(d.weekday)) expected++;
    }

    if (expected == 0) return 0.0;

    // Count completed days that fall on an expected weekday.
    final completedSet = completedDates.map(_dateOnly).toSet();
    int completed = 0;
    for (var d = start;
        !d.isAfter(today);
        d = d.add(const Duration(days: 1))) {
      if (activeWeekdays.contains(d.weekday) && completedSet.contains(d)) {
        completed++;
      }
    }

    return completed / expected;
  }

  /// Toggle today's completion status. Returns `true` if now completed.
  bool toggleToday() {
    final today = _dateOnly(DateTime.now());
    final idx = completedDates.indexWhere((d) => _dateOnly(d) == today);
    if (idx != -1) {
      completedDates.removeAt(idx);
      return false;
    } else {
      completedDates.add(today);
      return true;
    }
  }

  @override
  String toString() => 'Habit(id: $id, name: $name, streak: ${getCurrentStreak()})';
}
