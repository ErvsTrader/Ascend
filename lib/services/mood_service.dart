import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/mood_entry.dart';

// ---------------------------------------------------------------------------
// MoodService – mood logging & analytics backed by Hive
// ---------------------------------------------------------------------------

class MoodService extends ChangeNotifier {
  static const String _boxName = 'mood_entries';

  Box<MoodEntry> get _box => Hive.box<MoodEntry>(_boxName);

  // ── Helper ──────────────────────────────────────────────────────────────

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ── Create ──────────────────────────────────────────────────────────────

  /// Logs a new mood entry. If an entry for the same calendar day already
  /// exists, it is overwritten so there is at most one entry per day.
  Future<MoodEntry> addMoodEntry({
    required String moodType,
    String note = '',
    List<String>? habitIdsCompleted,
    DateTime? date,
  }) async {
    try {
      final entryDate = date ?? DateTime.now();
      final key = _keyForDate(entryDate);

      final entry = MoodEntry(
        date: entryDate,
        moodType: moodType,
        note: note,
        habitIdsCompleted: habitIdsCompleted,
      );

      await _box.put(key, entry);
      notifyListeners();
      return entry;
    } catch (e) {
      debugPrint('MoodService.addMoodEntry error: $e');
      rethrow;
    }
  }

  // ── Read ────────────────────────────────────────────────────────────────

  /// Returns the mood entry for a specific calendar day, or `null`.
  MoodEntry? getMoodByDate(DateTime date) {
    try {
      final key = _keyForDate(date);
      return _box.get(key);
    } catch (e) {
      debugPrint('MoodService.getMoodByDate error: $e');
      return null;
    }
  }

  /// All mood entries, most recent first.
  List<MoodEntry> getAllEntries() {
    try {
      return _box.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('MoodService.getAllEntries error: $e');
      return [];
    }
  }

  /// Entries within [start] .. [end] (inclusive), most recent first.
  List<MoodEntry> getEntriesInRange(DateTime start, DateTime end) {
    try {
      final s = _dateOnly(start);
      final e = _dateOnly(end).add(const Duration(days: 1));
      return _box.values
          .where((m) => !m.date.isBefore(s) && m.date.isBefore(e))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('MoodService.getEntriesInRange error: $e');
      return [];
    }
  }

  // ── Analytics ───────────────────────────────────────────────────────────

  /// Average `moodScore` across the given date range.
  /// Returns `null` if there are no entries in the range.
  double? getAverageMood(DateTime start, DateTime end) {
    try {
      final entries = getEntriesInRange(start, end);
      if (entries.isEmpty) return null;

      final total = entries.fold<double>(0, (sum, e) => sum + e.moodScore);
      return total / entries.length;
    } catch (e) {
      debugPrint('MoodService.getAverageMood error: $e');
      return null;
    }
  }

  /// Returns a map of { habitId → averageMoodScore } for days on which
  /// each habit was completed.
  ///
  /// This enables the Stats screen to show mood–habit correlation, e.g.
  /// "You feel best on days you do Meditation (avg 4.3)."
  Map<String, double> getMoodHabitCorrelation() {
    try {
      final entries = _box.values.toList();

      // Sum of mood scores and count per habit.
      final sums = <String, double>{};
      final counts = <String, int>{};

      for (final entry in entries) {
        for (final habitId in entry.habitIdsCompleted) {
          sums[habitId] = (sums[habitId] ?? 0) + entry.moodScore;
          counts[habitId] = (counts[habitId] ?? 0) + 1;
        }
      }

      // Compute averages.
      final result = <String, double>{};
      for (final id in sums.keys) {
        result[id] = sums[id]! / counts[id]!;
      }

      return result;
    } catch (e) {
      debugPrint('MoodService.getMoodHabitCorrelation error: $e');
      return {};
    }
  }

  /// Average mood score across all entries (for the Stats screen "4.2 Avg Mood").
  double? get overallAverageMood {
    final entries = _box.values.toList();
    if (entries.isEmpty) return null;
    final total = entries.fold<double>(0, (sum, e) => sum + e.moodScore);
    return total / entries.length;
  }

  /// Total number of check-ins ever recorded.
  int get totalCheckIns => _box.length;

  // ── Private ─────────────────────────────────────────────────────────────

  /// Deterministic Hive key for a calendar day → `"YYYY-MM-DD"`.
  String _keyForDate(DateTime dt) {
    final d = _dateOnly(dt);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
