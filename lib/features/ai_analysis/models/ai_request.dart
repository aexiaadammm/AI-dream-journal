import '../../journal/models/dream_entry.dart';
import '../../journal/models/follow_up_answers.dart';

class AIRequest {
  const AIRequest({required this.dream, required this.followUpAnswers});

  final DreamEntry dream;
  final FollowUpAnswers followUpAnswers;

  Map<String, Object?> toJson() {
    return {
      'dream': {
        'id': dream.id,
        'title': dream.title,
        'description': dream.description,
        'mood': dream.mood,
        'createdAt': dream.createdAt.toIso8601String(),
      },
      'followUpAnswers': {
        'dreamId': followUpAnswers.dreamId,
        'emotions': followUpAnswers.emotions,
        'stressLevel': followUpAnswers.stressLevel,
        'sleepQuality': followUpAnswers.sleepQuality,
        'beliefs': followUpAnswers.beliefs,
        'culturalBackground': followUpAnswers.culturalBackground,
        'recentLifeEvents': followUpAnswers.recentLifeEvents,
        'isRecurring': followUpAnswers.isRecurring,
      },
    };
  }
}
