import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_request.dart';
import '../models/ai_response.dart';

class ApiClient {
  const ApiClient({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;

  Future<AIResponse> analyzeDream(AIRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': 'default-user',
        'dreamId': request.dream.id,
        'dreamText': request.dream.description,
        'emotions': request.followUpAnswers.emotions,
        'sleepQuality': request.followUpAnswers.sleepQuality,
        'stressLevel': request.followUpAnswers.stressLevel,
        'people': null,
        'places': null,
        'symbols': null,
        'culturalBackground': request.followUpAnswers.culturalBackground,
        'beliefs': request.followUpAnswers.beliefs,
        'profession': null,
        'recentLifeEvents': request.followUpAnswers.recentLifeEvents,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Dream analysis failed: ${response.statusCode}');
    }

    return AIResponse.fromJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
  }
}
