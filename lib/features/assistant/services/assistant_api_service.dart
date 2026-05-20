import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/assistant_context.dart';
import '../models/assistant_response.dart';

class AssistantApiService {
  const AssistantApiService({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;

  Future<String> reply({
    required AssistantContext context,
    required String userMessage,
  }) async {
    final dream = context.dream;
    final answers = context.followUpAnswers;
    final profile = context.userProfile;

    final response = await http.post(
      Uri.parse('$baseUrl/api/assistant/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': profile?.name ?? 'default-user',
        'dreamId': dream.id,
        'mode': context.mode.name,
        'message': userMessage,
        'dreamText': dream.description,
        'emotions': answers?.emotions ?? dream.mood,
        'sleepQuality': answers?.sleepQuality,
        'stressLevel': answers?.stressLevel,
        'people': null,
        'places': null,
        'symbols': null,
        'culturalBackground':
            answers?.culturalBackground ?? profile?.culturalBackground,
        'beliefs': answers?.beliefs,
        'profession': profile?.professionOrInterest,
        'recentLifeEvents': answers?.recentLifeEvents,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Assistant request failed: ${response.statusCode}');
    }

    final assistantResponse = AssistantResponse.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
    return assistantResponse.toDisplayText();
  }
}
