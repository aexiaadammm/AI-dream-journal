import '../models/ai_request.dart';
import '../models/ai_response.dart';

class ApiClient {
  const ApiClient({this.baseUrl = 'https://your-backend.example.com'});

  final String baseUrl;

  Future<AIResponse> analyzeDream(AIRequest request) {
    // Future backend integration point:
    // POST $baseUrl/api/dream-analysis with request.toJson().
    // The backend should keep the OpenAI API key server-side and return
    // structured JSON matching AIResponse.
    throw UnimplementedError('Real backend AI analysis is not connected yet.');
  }
}
