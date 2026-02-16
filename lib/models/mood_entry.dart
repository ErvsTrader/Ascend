import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

/// Hive type ID for [MoodEntry].
const int moodEntryTypeId = 1;

// ---------------------------------------------------------------------------
// Valid mood types (matches Visily Mood Check-in screen)
// ---------------------------------------------------------------------------

/// All supported mood types.
const List<String> moodTypes = [
  'ecstatic',
  'happy',
  'calm',
  'neutral',
  'tired',
  'sad',
  'stressed',
  'grateful',
  'gloomy',
];

// ---------------------------------------------------------------------------
// MoodEntry model
// ---------------------------------------------------------------------------

@HiveType(typeId: moodEntryTypeId)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  String moodType;

  @HiveField(2)
  String note;

  @HiveField(3)
  List<String> habitIdsCompleted;

  MoodEntry({
    DateTime? date,
    required this.moodType,
    this.note = '',
    List<String>? habitIdsCompleted,
  })  : date = date ?? DateTime.now(),
        habitIdsCompleted = habitIdsCompleted ?? [] {
    assert(
      moodTypes.contains(moodType),
      'Invalid moodType "$moodType". Must be one of: $moodTypes',
    );
  }

  /// Numeric score for averaging (1 = gloomy … 5 = ecstatic).
  double get moodScore {
    const scores = <String, double>{
      'gloomy': 1.0,
      'sad': 1.5,
      'stressed': 2.0,
      'tired': 2.5,
      'neutral': 3.0,
      'calm': 3.5,
      'grateful': 4.0,
      'happy': 4.5,
      'ecstatic': 5.0,
    };
    return scores[moodType] ?? 3.0;
  }

  /// Emoji mapped to each mood type for display.
  String get moodEmoji {
    const emojis = <String, String>{
      'ecstatic': '🤩',
      'happy': '😊',
      'calm': '😌',
      'neutral': '😐',
      'tired': '🌙',
      'sad': '😢',
      'stressed': '⚡',
      'grateful': '❤️',
      'gloomy': '😞',
    };
    return emojis[moodType] ?? '😐';
  }

  /// Capitalised label for display.
  String get moodLabel =>
      moodType[0].toUpperCase() + moodType.substring(1);

  @override
  String toString() =>
      'MoodEntry(date: $date, mood: $moodType, note: "$note")';
}
