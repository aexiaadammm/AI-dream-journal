import '../models/ai_request.dart';
import '../models/ai_response.dart';

class MockAIAnalysisProvider {
  const MockAIAnalysisProvider();

  Future<AIResponse> analyze(AIRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    final dream = request.dream;
    final answers = request.followUpAnswers;
    final text = dream.description.toLowerCase();
    final symbols = <String>[];

    if (text.contains('water') ||
        text.contains('sea') ||
        text.contains('rain')) {
      symbols.add('Water or rain may point to emotional movement.');
    }
    if (text.contains('house') || text.contains('home')) {
      symbols.add('A house can represent safety, identity, or private life.');
    }
    if (text.contains('run') || text.contains('chase')) {
      symbols.add('Running or being chased may reflect pressure or avoidance.');
    }
    if (text.contains('family') ||
        text.contains('mother') ||
        text.contains('father')) {
      symbols.add('Family figures may connect to belonging or old patterns.');
    }
    if (symbols.isEmpty) {
      symbols.add(
        'The strongest symbols may be personal details you remember most clearly.',
      );
      symbols.add('Mood and setting are useful starting points.');
    }

    final tone = answers.stressLevel >= 7
        ? 'The dream carries a tense emotional tone, shaped by ${answers.emotions.toLowerCase()} and a high stress level.'
        : 'The dream seems emotionally reflective, with ${answers.emotions.toLowerCase()} present but not overwhelming.';

    final recurringNote = answers.isRecurring
        ? 'Because this dream is recurring, it may be worth tracking what changes each time it appears.'
        : 'Because this dream is not recurring, treat it as a snapshot of your current inner context.';

    return AIResponse(
      emotionalTone: tone,
      possibleSymbols: symbols,
      contextualInterpretation:
          'From a ${answers.culturalBackground.toLowerCase()} context and a ${answers.beliefs.toLowerCase()} belief lens, this dream can be explored as a personal reflection rather than a fixed meaning. $recurringNote Recent events you mentioned: ${answers.recentLifeEvents}. Sleep quality was ${answers.sleepQuality.toLowerCase()}, which can shape dream intensity.',
      reflectionQuestions: [
        'Which part of the dream felt most alive when you woke up?',
        'Does the main emotion connect with anything happening this week?',
        'What would feel grounding after this dream today?',
      ],
      dailyAdvice:
          'Take ten quiet minutes today to write one thing you can release and one small action that would make you feel steadier.',
      dreamTypeFindings: [
        'Recurring Dreams: These frequently reflect ongoing personal conflicts or stress.',
        'Lucid Dreams: A state where the dreamer is aware they are dreaming, allowing for potential interaction and influence over dream content.',
        'Nightmares: Often studied as failed emotional regulation, these are a focus of clinical treatment aimed at modifying content to improve mental health.',
      ],
      disclaimer:
          'This is a reflective wellness interpretation, not a medical diagnosis or a replacement for professional care.',
    );
  }
}
