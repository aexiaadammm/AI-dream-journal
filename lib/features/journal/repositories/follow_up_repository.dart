import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/follow_up_answers.dart';

class FollowUpRepository {
  static const _answersKey = 'follow_up_answers';
  static const _nextAnswerIdKey = 'next_follow_up_answer_id';

  Future<int> saveAnswers(FollowUpAnswers answers) async {
    final preferences = await SharedPreferences.getInstance();
    final answerId = preferences.getInt(_nextAnswerIdKey) ?? 1;
    final savedAnswers = await _getAllAnswers();

    savedAnswers.add(
      FollowUpAnswers(
        id: answerId,
        dreamId: answers.dreamId,
        emotions: answers.emotions,
        stressLevel: answers.stressLevel,
        sleepQuality: answers.sleepQuality,
        beliefs: answers.beliefs,
        culturalBackground: answers.culturalBackground,
        recentLifeEvents: answers.recentLifeEvents,
        isRecurring: answers.isRecurring,
        createdAt: answers.createdAt,
      ),
    );

    await preferences.setString(
      _answersKey,
      jsonEncode(savedAnswers.map((answers) => answers.toMap()).toList()),
    );
    await preferences.setInt(_nextAnswerIdKey, answerId + 1);

    return answerId;
  }

  Future<FollowUpAnswers?> getLatestAnswersForDream(int dreamId) async {
    final answers = await _getAllAnswers();
    final matchingAnswers = answers
        .where((answers) => answers.dreamId == dreamId)
        .toList();

    if (matchingAnswers.isEmpty) {
      return null;
    }

    matchingAnswers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return matchingAnswers.first;
  }

  Future<List<FollowUpAnswers>> _getAllAnswers() async {
    final preferences = await SharedPreferences.getInstance();
    final rawAnswers = preferences.getString(_answersKey);

    if (rawAnswers == null) {
      return [];
    }

    final decodedAnswers = jsonDecode(rawAnswers) as List;
    return decodedAnswers
        .map(
          (answers) => FollowUpAnswers.fromMap(
            Map<String, Object?>.from(answers as Map),
          ),
        )
        .toList();
  }
}
