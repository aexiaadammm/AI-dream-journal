class AIResponse {
  const AIResponse({
    required this.emotionalTone,
    required this.possibleSymbols,
    required this.contextualInterpretation,
    required this.reflectionQuestions,
    required this.dailyAdvice,
    required this.dreamTypeFindings,
    required this.disclaimer,
  });

  final String emotionalTone;
  final List<String> possibleSymbols;
  final String contextualInterpretation;
  final List<String> reflectionQuestions;
  final String dailyAdvice;
  final List<String> dreamTypeFindings;
  final String disclaimer;

  factory AIResponse.fromJson(Map<String, Object?> json) {
    return AIResponse(
      emotionalTone: json['emotionalTone'] as String,
      possibleSymbols: List<String>.from(json['possibleSymbols'] as List),
      contextualInterpretation: json['contextualInterpretation'] as String,
      reflectionQuestions: List<String>.from(
        json['reflectionQuestions'] as List,
      ),
      dailyAdvice: json['dailyAdvice'] as String,
      dreamTypeFindings: List<String>.from(json['dreamTypeFindings'] as List),
      disclaimer: json['disclaimer'] as String,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'emotionalTone': emotionalTone,
      'possibleSymbols': possibleSymbols,
      'contextualInterpretation': contextualInterpretation,
      'reflectionQuestions': reflectionQuestions,
      'dailyAdvice': dailyAdvice,
      'dreamTypeFindings': dreamTypeFindings,
      'disclaimer': disclaimer,
    };
  }
}
