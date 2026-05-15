import '../models/ai_request.dart';
import '../models/ai_response.dart';
import 'api_client.dart';
import 'mock_ai_analysis_provider.dart';

class AIAnalysisService {
  const AIAnalysisService({
    this.useMockProvider = true,
    this.apiClient = const ApiClient(),
    this.mockProvider = const MockAIAnalysisProvider(),
  });

  final bool useMockProvider;
  final ApiClient apiClient;
  final MockAIAnalysisProvider mockProvider;

  Future<AIResponse> analyzeDream(AIRequest request) {
    if (useMockProvider) {
      return mockProvider.analyze(request);
    }

    return apiClient.analyzeDream(request);
  }
}
