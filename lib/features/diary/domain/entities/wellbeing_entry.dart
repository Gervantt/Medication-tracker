import 'package:equatable/equatable.dart';

class WellbeingEntry extends Equatable {
  const WellbeingEntry({
    required this.date,
    required this.mood,
    this.symptoms = const [],
    this.note,
  }) : assert(mood >= minMood && mood <= maxMood, 'mood must be in 1..5');

  static const minMood = 1;
  static const maxMood = 5;

  /// Local midnight of the day the entry belongs to.
  final DateTime date;

  /// 1 (very bad) .. 5 (very good).
  final int mood;

  /// Predefined symptom keys or custom text entered by the user.
  final List<String> symptoms;
  final String? note;

  @override
  List<Object?> get props => [date, mood, symptoms, note];
}
