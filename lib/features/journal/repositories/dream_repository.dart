import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/dream_entry.dart';

class DreamRepository {
  DreamRepository({this.baseUrl = 'http://localhost:8080'});

  final String baseUrl;

  Future<int> addDream(DreamEntry dream) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/dreams'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': 'default-user',
        'title': dream.title,
        'dreamText': dream.description,
        'mood': dream.mood,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not save dream: ${response.statusCode}');
    }

    final savedDream = DreamEntry.fromApiJson(
      jsonDecode(response.body) as Map<String, Object?>,
    );
    return savedDream.id!;
  }

  Future<List<DreamEntry>> getDreams() async {
    final response = await http.get(Uri.parse('$baseUrl/api/dreams'));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not load dreams: ${response.statusCode}');
    }

    final decodedDreams = jsonDecode(response.body) as List;
    return decodedDreams
        .map(
          (dream) => DreamEntry.fromApiJson(
            Map<String, Object?>.from(dream as Map),
          ),
        )
        .toList();
  }
}
