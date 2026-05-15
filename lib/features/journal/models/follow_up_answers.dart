class FollowUpAnswers {
  const FollowUpAnswers({
    this.id,
    required this.dreamId,
    required this.emotions,
    required this.stressLevel,
    required this.sleepQuality,
    required this.beliefs,
    required this.culturalBackground,
    required this.recentLifeEvents,
    required this.isRecurring,
    required this.createdAt,
  });

  final int? id;
  final int dreamId;
  final String emotions;
  final int stressLevel;
  final String sleepQuality;
  final String beliefs;
  final String culturalBackground;
  final String recentLifeEvents;
  final bool isRecurring;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'dream_id': dreamId,
      'emotions': emotions,
      'stress_level': stressLevel,
      'sleep_quality': sleepQuality,
      'beliefs': beliefs,
      'cultural_background': culturalBackground,
      'recent_life_events': recentLifeEvents,
      'is_recurring': isRecurring ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory FollowUpAnswers.fromMap(Map<String, Object?> map) {
    return FollowUpAnswers(
      id: map['id'] as int?,
      dreamId: map['dream_id'] as int,
      emotions: map['emotions'] as String,
      stressLevel: map['stress_level'] as int,
      sleepQuality: map['sleep_quality'] as String,
      beliefs: map['beliefs'] as String,
      culturalBackground: map['cultural_background'] as String,
      recentLifeEvents: map['recent_life_events'] as String,
      isRecurring: map['is_recurring'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
