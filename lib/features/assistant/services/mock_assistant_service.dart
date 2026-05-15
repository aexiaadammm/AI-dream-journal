import '../models/assistant_context.dart';
import '../models/assistant_mode.dart';

class MockAssistantService {
  const MockAssistantService();

  Future<String> reply({
    required AssistantContext context,
    required String userMessage,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    return switch (context.mode) {
      AssistantMode.reflection => _reflectionReply(context, userMessage),
      AssistantMode.creativeTransformation =>
        _creativeTransformationReply(context, userMessage),
    };
  }

  String _reflectionReply(AssistantContext context, String userMessage) {
    final answers = context.followUpAnswers;
    final profile = context.userProfile;
    final emotion = answers?.emotions.toLowerCase() ?? 'mixed emotions';
    final beliefs = answers?.beliefs.toLowerCase() ?? 'your own belief lens';
    final culture = answers?.culturalBackground ??
        profile?.culturalBackground ??
        'your background';

    return 'Reflection mode: for your question "$userMessage", your dream "${context.dream.title}" seems connected to $emotion and can be explored through $beliefs. From a $culture context, I would treat the dream as a personal reflection, not a fixed prediction. A gentle next step: write one sentence about what this dream asks you to notice today. This is not diagnosis or therapy, and it does not replace professional help.';
  }

  String _creativeTransformationReply(
    AssistantContext context,
    String userMessage,
  ) {
    final dream = context.dream;
    final profile = context.userProfile;
    final answers = context.followUpAnswers;
    final profession = profile?.professionOrInterest ?? 'your daily work';
    final nationality = profile?.nationality ?? 'your cultural background';
    final symbols = _extractSymbols(dream.description);
    final symbolText = symbols.isEmpty ? 'the strongest image' : symbols.first;

    if (_isRomanianTeacherBuildingExample(
      dream.description,
      profession,
      nationality,
    )) {
      return 'Creative Transformation mode: because you are a Romanian teacher and the dream image is a 10-floor building, turn it into a lesson structure. Use 10 sheets of paper, each sheet as one "floor" of a literary text: theme, narrator, characters, conflict, setting, symbols, language, perspective, structure, and message. Students connect the sheets vertically to build the text as an architectural model. Keep it playful and reflective, not diagnostic.';
    }

    return 'Creative Transformation mode: for "$userMessage", take "$symbolText" from "${dream.title}" and translate it into $profession. Create a small practical exercise with 3 steps: name the symbol, connect it to one real task, then turn it into a visible artifact such as a checklist, sketch, lesson, plan, or prototype. Your context: ${answers?.emotions ?? 'emotion not recorded'}, ${answers?.beliefs ?? 'belief lens not recorded'}, ${profile?.culturalBackground ?? 'culture not recorded'}. This is creative coaching, not therapy or medical advice.';
  }

  List<String> _extractSymbols(String description) {
    final text = description.toLowerCase();
    final symbols = <String>[];

    if (text.contains('building')) {
      symbols.add('building');
    }
    if (text.contains('water') ||
        text.contains('rain') ||
        text.contains('sea')) {
      symbols.add('water');
    }
    if (text.contains('house') || text.contains('home')) {
      symbols.add('home');
    }
    if (text.contains('road') || text.contains('path')) {
      symbols.add('path');
    }
    if (text.contains('school') || text.contains('class')) {
      symbols.add('school');
    }

    return symbols;
  }

  bool _isRomanianTeacherBuildingExample(
    String dreamDescription,
    String profession,
    String nationality,
  ) {
    final text = dreamDescription.toLowerCase();
    return nationality.toLowerCase().contains('romanian') &&
        profession.toLowerCase().contains('teacher') &&
        text.contains('building') &&
        (text.contains('10') || text.contains('ten'));
  }
}
