import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/habit.dart';

// ---------------------------------------------------------------------------
// HabitService – CRUD + completion tracking backed by Hive
// ---------------------------------------------------------------------------

class HabitService extends ChangeNotifier {
  static const String _boxName = 'habits';

  Box<Habit> get _box => Hive.box<Habit>(_boxName);

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
  Future<Habit> addHabit({
    required String name,
    required String category,
    required int colorValue,
    required List<String> frequency,
    int reminderHour = 8,
    int reminderMinute = 0,
  }) async {
    try {
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
  int get completedTodayCount =>
      getAllHabits().where((h) => h.isCompletedToday()).length;

  /// Total active habit count.
  int get totalCount => _box.length;

  /// Today's completion fraction (0.0 – 1.0).
  double get todayProgress {
    final total = totalCount;
    if (total == 0) return 0.0;
    return completedTodayCount / total;
  }
}
