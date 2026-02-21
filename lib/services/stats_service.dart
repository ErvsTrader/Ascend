import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_service.dart';
import 'mood_service.dart';
import '../models/mood_entry.dart';

// ---------------------------------------------------------------------------
// StatsService – handles complex calculations and stats caching
// ---------------------------------------------------------------------------

class StatsService extends ChangeNotifier {
  final HabitService habitService;
  final MoodService moodService;

  StatsService({required this.habitService, required this.moodService});

  static const String _cacheKey = 'stats_cache';
  static const String _lastUpdateKey = 'stats_last_update';

  Map<String, dynamic>? _cachedStats;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// Loads stats either from cache or recalculates if 1 hour has passed.
  Future<void> loadStats({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      if (!forceRefresh && 
          _cachedStats != null && 
          (now - lastUpdate) < 3600000) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Recalculate everything
      final stats = await _calculateAll();
      
      _cachedStats = stats;
      await prefs.setString(_cacheKey, jsonEncode(stats));
      await prefs.setInt(_lastUpdateKey, now);
    } catch (e) {
      debugPrint('StatsService.loadStats error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _calculateAll() async {
    final weeklyCompletion = calculateWeeklyCompletion();
    final trend = calculateCompletionTrend();
    final bestStreak = getBestStreak();
    final overallCompletion = getOverallCompletion();
    final avgMood = getAverageMood();
    final totalCheckIns = getTotalCheckIns();
    final progressText = getProgressReportText(overallCompletion['percentage'] as double);

    return {
      'weeklyCompletion': weeklyCompletion,
      'trend': trend,
      'bestStreak': bestStreak,
      'overallCompletion': overallCompletion,
      'avgMood': avgMood,
      'totalCheckIns': totalCheckIns,
      'progressText': progressText,
    };
  }

  // 1. calculateWeeklyCompletion()
  Map<String, double> calculateWeeklyCompletion() {
    final result = <String, double>{};
    final now = DateTime.now();
    
    // Last 7 days including today
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final percent = habitService.getProgressForDate(date) * 100;
      result[dayName] = percent;
    }
    return result;
  }

  // 2. calculateCompletionTrend()
  String calculateCompletionTrend() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // This week (last 7 days)
    final thisWeekStart = today.subtract(const Duration(days: 6));
    final thisWeekAvg = habitService.getCompletionRateInRange(thisWeekStart, today) * 100;
    
    // Last week (days 8-14 ago)
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));
    final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
    final lastWeekAvg = habitService.getCompletionRateInRange(lastWeekStart, lastWeekEnd) * 100;
    
    if (lastWeekAvg == 0) return thisWeekAvg > 0 ? '+${thisWeekAvg.toInt()}%' : '0%';
    
    final diff = thisWeekAvg - lastWeekAvg;
    final sign = diff >= 0 ? '+' : '';
    return '$sign${diff.toInt()}%';
  }

  // 3. getBestStreak()
  Map<String, dynamic> getBestStreak() {
    final habits = habitService.getAllHabits();
    if (habits.isEmpty) return {'habitName': 'No habits', 'streak': 0, 'improvement': 0};

    var bestHabit = habits.first;
    var maxStreak = -1;

    for (final habit in habits) {
      final streak = habit.getCurrentStreak();
      if (streak > maxStreak) {
        maxStreak = streak;
        bestHabit = habit;
      }
    }

    // "Improvement" is a bit arbitrary here without historic streak tracking, 
    // mock it as +3 for now or calculate if possible.
    return {
      'habitName': bestHabit.name,
      'streak': maxStreak,
      'improvement': 3, // Per spec
    };
  }

  // 4. getOverallCompletion()
  Map<String, dynamic> getOverallCompletion() {
    final habits = habitService.getAllHabits();
    if (habits.isEmpty) return {'percentage': 0.0, 'badge': 'Needs Work'};

    int totalPossible = 0;
    int totalCompleted = 0;

    for (final habit in habits) {
      totalCompleted += habit.completedDates.length;
      // Approximate total possible as (days since created)
      final daysSinceCreated = DateTime.now().difference(habit.createdDate).inDays + 1;
      totalPossible += daysSinceCreated;
    }

    final percentage = totalPossible > 0 ? (totalCompleted / totalPossible) * 100 : 0.0;
    String badge = 'Needs Work';
    if (percentage > 75) badge = 'Good';
    else if (percentage >= 50) badge = 'Average';

    return {'percentage': percentage, 'badge': badge};
  }

  // 5. getAverageMood()
  Map<String, dynamic>? getAverageMood() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final entries = moodService.getEntriesInRange(start, now);
    
    if (entries.isEmpty) return null;

    final sum = entries.fold<double>(0, (prev, e) => prev + e.moodScore);
    final average = sum / entries.length;

    String description = "Mostly Neutral";
    if (average >= 4.0) description = "Mostly Happy & Positive";
    else if (average >= 3.5) description = "Mostly Calm & Focused";
    else if (average >= 2.0) description = "Sometimes Struggling";
    else if (average < 2.0) description = "Need Support";

    return {
      'average': double.parse(average.toStringAsFixed(1)),
      'description': description
    };
  }

  // 6. getTotalCheckIns()
  int getTotalCheckIns() {
    final habits = habitService.getAllHabits();
    return habits.fold<int>(0, (sum, h) => sum + h.completedDates.length);
  }

  // 7. getProgressReportText()
  String getProgressReportText(double percent) {
    if (percent > 90) return "You completed ${percent.toInt()}% of your habits this week. Outstanding work!";
    if (percent >= 70) return "You completed ${percent.toInt()}% of your habits this week. Keep ascending!";
    if (percent >= 50) return "You completed ${percent.toInt()}% of your habits this week. You're making progress!";
    return "You completed ${percent.toInt()}% of your habits this week. Every day is a fresh start!";
  }

  // Getters for individual stats (from cache)
  Map<String, double> get weeklyCompletionData => 
      Map<String, double>.from(_cachedStats?['weeklyCompletion'] ?? {});
  
  String get completionTrend => _cachedStats?['trend'] ?? '0%';
  
  Map<String, dynamic> get bestStreakData => 
      _cachedStats?['bestStreak'] ?? {'habitName': '--', 'streak': 0, 'improvement': 0};
  
  Map<String, dynamic> get overallCompletionData => 
      _cachedStats?['overallCompletion'] ?? {'percentage': 0.0, 'badge': 'Needs Work'};
  
  Map<String, dynamic>? get avgMoodData => _cachedStats?['avgMood'];
  
  int get totalCheckIns => _cachedStats?['totalCheckIns'] ?? 0;
  
  String get progressReportText => _cachedStats?['progressText'] ?? 'Keep moving forward!';

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }
}
