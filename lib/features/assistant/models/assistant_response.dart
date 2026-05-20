class AssistantResponse {
  const AssistantResponse({
    required this.possibleInterpretation,
    required this.emotionalThemes,
    required this.reflectionQuestions,
    required this.patternObservation,
    required this.companionMessage,
    required this.disclaimer,
  });

  final String possibleInterpretation;
  final List<String> emotionalThemes;
  final List<String> reflectionQuestions;
  final String patternObservation;
  final String companionMessage;
  final String disclaimer;

  factory AssistantResponse.fromJson(Map<String, Object?> json) {
    return AssistantResponse(
      possibleInterpretation: json['possibleInterpretation'] as String,
      emotionalThemes: List<String>.from(json['emotionalThemes'] as List),
      reflectionQuestions: List<String>.from(
        json['reflectionQuestions'] as List,
      ),
      patternObservation: json['patternObservation'] as String,
      companionMessage: json['companionMessage'] as String,
      disclaimer: json['disclaimer'] as String,
    );
  }

  String toDisplayText() {
    return [
      companionMessage,
      '',
      'Possible interpretation:',
      possibleInterpretation,
      '',
      'Emotional themes:',
      ...emotionalThemes.map((theme) => '- $theme'),
      '',
      'Reflection questions:',
      ...reflectionQuestions.map((question) => '- $question'),
      '',
      'Pattern observation:',
      patternObservation,
      '',
      disclaimer,
    ].join('\n');
  }
}
