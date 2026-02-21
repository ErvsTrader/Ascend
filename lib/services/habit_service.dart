import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/habit.dart';
import 'notification_service.dart';

// ---------------------------------------------------------------------------
// HabitService – CRUD + completion tracking backed by Hive
// ---------------------------------------------------------------------------

class HabitService extends ChangeNotifier {
  static const String _boxName = 'habits';

  Box<Habit> get _box => Hive.box<Habit>(_boxName);

  final NotificationService _notifications = NotificationService();

  /// Counter for completions to trigger ads.
  int _completionsSinceLastAd = 0;

  /// Whether an ad should be shown (every 5 completions).
  bool get shouldShowAd => _completionsSinceLastAd >= 5;

  /// Resets the ad counter after showing an ad.
  void resetAdCounter() {
    _completionsSinceLastAd = 0;
    notifyListeners();
  }

  // ── Read ────────────────────────────────────────────────────────────────

  /// All habits, ordered by creation date (newest first).
  List<Habit> getAllHabits() {
    try {
      final habits = _box.values.toList()
        ..sort((a, b) => b.createdDate.compareTo(a.createdDate));
      return habits;
    } catch (e) {
      debugPrint('HabitService.getAllHabits error: $e');
      return [];
    }
  }

  /// Getter for all habits (alias for getAllHabits)
  List<Habit> get habits => getAllHabits();

  /// Single habit by [id], or `null` if not found.
  Habit? getHabitById(String id) {
    try {
      return _box.values.firstWhere((h) => h.id == id);
    } catch (e) {
      debugPrint('HabitService.getHabitById error: $e');
      return null;
    }
  }

  // ── Create ──────────────────────────────────────────────────────────────

  /// Adds a new habit and persists it. Returns the created [Habit].
  /// Throws an exception if the 5-habit limit is reached for free users.
  Future<Habit> addHabit({
    required String name,
    required String category,
    required int colorValue,
    required List<String> frequency,
    required bool isPremium,
    int reminderHour = 8,
    int reminderMinute = 0,
    String? sound,
  }) async {
    try {
      if (!isPremium && totalCount >= 5) {
        throw Exception('Free tier limit reached (5 habits max). Upgrade to Premium to add more!');
      }

      final habit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        category: category,
        colorValue: colorValue,
        frequency: frequency,
        reminderHour: reminderHour,
        reminderMinute: reminderMinute,
      );
      await _box.put(habit.id, habit);
      
      // Schedule reminder
      await _notifications.scheduleHabitReminder(habit, sound: sound);
      
      notifyListeners();
      return habit;
    } catch (e) {
      debugPrint('HabitService.addHabit error: $e');
      rethrow;
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────

  /// Updates an existing habit's editable fields and persists changes.
  Future<void> updateHabit({
    required String id,
    String? name,
    String? category,
    int? colorValue,
    List<String>? frequency,
    int? reminderHour,
    int? reminderMinute,
    String? sound,
  }) async {
    try {
      final habit = getHabitById(id);
      if (habit == null) {
        throw Exception('Habit with id "$id" not found');
      }

      if (name != null) habit.name = name;
      if (category != null) habit.category = category;
      if (colorValue != null) habit.colorValue = colorValue;
      if (frequency != null) habit.frequency = frequency;
      if (reminderHour != null) habit.reminderHour = reminderHour;
      if (reminderMinute != null) habit.reminderMinute = reminderMinute;

      await habit.save();

      // Reschedule reminder
      await _notifications.scheduleHabitReminder(habit, sound: sound);

      notifyListeners();
    } catch (e) {
      debugPrint('HabitService.updateHabit error: $e');
      rethrow;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────

  /// Permanently deletes a habit by [id].
  Future<void> deleteHabit(String id) async {
    try {
      await _box.delete(id);
      
      // Cancel reminder
      await _notifications.cancelHabitReminder(id);
      
      notifyListeners();
    } catch (e) {
      debugPrint('HabitService.deleteHabit error: $e');
      rethrow;
    }
  }

  // ── Completion ──────────────────────────────────────────────────────────

  /// Marks a habit as completed for the given [date].
  /// If already completed for that date, it toggles it off.
  /// Returns `true` if the habit is now marked complete for that date.
  Future<bool> markComplete(String habitId, DateTime date) async {
    try {
      final habit = getHabitById(habitId);
      if (habit == null) {
        throw Exception('Habit with id "$habitId" not found');
      }

      final dateOnly = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);

      // Block future dates
      if (dateOnly.isAfter(todayOnly)) {
        return false;
      }

      final idx = habit.completedDates.indexWhere(
        (d) => DateTime(d.year, d.month, d.day) == dateOnly,
      );

      bool completed;
      if (idx != -1) {
        habit.completedDates.removeAt(idx);
        completed = false;
      } else {
        habit.completedDates.add(dateOnly);
        completed = true;
        _completionsSinceLastAd++;
      }

      await habit.save();
      notifyListeners();
      return completed;
    } catch (e) {
      debugPrint('HabitService.markComplete error: $e');
      rethrow;
    }
  }

  // ── Aggregate helpers ───────────────────────────────────────────────────

  /// Number of habits completed today.
  int get completedTodayCount => getCompletedCountForDate(DateTime.now());

  /// Number of habits completed on a specific [date].
  int getCompletedCountForDate(DateTime date) {
    final habits = getAllHabits();
    return habits.where((h) => h.isCompletedOn(date)).length;
  }

  /// Total active habit count.
  int get totalCount => _box.length;

  /// Today's completion fraction (0.0 – 1.0).
  double get todayProgress => getProgressForDate(DateTime.now());

  /// Completion fraction (0.0 – 1.0) for a specific [date].
  double getProgressForDate(DateTime date) {
    final total = totalCount;
    if (total == 0) return 0.0;
    return getCompletedCountForDate(date) / total;
  }

  /// Completion rate (0.0 - 1.0) for a specific date range across all habits.
  double getCompletionRateInRange(DateTime start, DateTime end) {
    final habits = getAllHabits();
    if (habits.isEmpty) return 0.0;

    int totalExpected = 0;
    int totalCompleted = 0;

    for (final habit in habits) {
      // Habit model already has getSuccessRate logic, but we need it for a specific range.
      // For simplicity, we aggregate daily check-ins.
      final s = DateTime(start.year, start.month, start.day);
      final e = DateTime(end.year, end.month, end.day);

      // Map weekday name → DateTime.weekday int
      final weekdayMap = {
        'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7,
      };
      final activeWeekdays = habit.frequency.map((f) => weekdayMap[f]).toSet();

      for (var d = s; !d.isAfter(e); d = d.add(const Duration(days: 1))) {
        // Only count days after habit was created and if it's a scheduled day
        if (!d.isBefore(DateTime(habit.createdDate.year, habit.createdDate.month, habit.createdDate.day)) &&
            activeWeekdays.contains(d.weekday)) {
          totalExpected++;
          if (habit.completedDates.any((cd) => 
              cd.year == d.year && cd.month == d.month && cd.day == d.day)) {
            totalCompleted++;
          }
        }
      }
    }

    if (totalExpected == 0) return 0.0;
    return totalCompleted / totalExpected;
  }

  /// Returns a list of daily completion percentages for the last [days] days.
  List<double> getDailyCompletionRates(int days) {
    final now = DateTime.now();
    return List.generate(days, (index) {
      final date = now.subtract(Duration(days: (days - 1) - index));
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      final habits = getAllHabits();
      if (habits.isEmpty) return 0.0;

      int expected = 0;
      int completed = 0;

      final weekdayMap = {
        'Mon': 1, 'Tue': 2, 'Wed': 3, 'Thu': 4, 'Fri': 5, 'Sat': 6, 'Sun': 7,
      };

      for (final habit in habits) {
        final activeWeekdays = habit.frequency.map((f) => weekdayMap[f]).toSet();
        if (!dateOnly.isBefore(DateTime(habit.createdDate.year, habit.createdDate.month, habit.createdDate.day)) &&
            activeWeekdays.contains(dateOnly.weekday)) {
          expected++;
          if (habit.completedDates.any((cd) => 
              cd.year == dateOnly.year && cd.month == dateOnly.month && cd.day == dateOnly.day)) {
            completed++;
          }
        }
      }
      
      if (expected == 0) return 0.0;
      return completed / expected;
    });
  }

  /// Max streak achieved across all active habits.
  int getGlobalBestStreak() {
    final habits = getAllHabits();
    if (habits.isEmpty) return 0;
    return habits.fold(0, (max, h) => h.getBestStreak() > max ? h.getBestStreak() : max);
  }

  /// Total completions across all habits ever.
  int getTotalGlobalCheckIns() {
    return getAllHabits().fold(0, (sum, h) => sum + h.completedDates.length);
  }

  /// Comparison indicator (percentage points) vs previous 7 days.
  double getCompletionPointTrend() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final currentStart = today.subtract(const Duration(days: 6));
    final prevEnd = today.subtract(const Duration(days: 7));
    final prevStart = today.subtract(const Duration(days: 13));

    final currentRate = getCompletionRateInRange(currentStart, today);
    final prevRate = getCompletionRateInRange(prevStart, prevEnd);

    return (currentRate - prevRate) * 100;
  }
}
