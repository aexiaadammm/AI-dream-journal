import 'package:flutter/material.dart';

import '../../journal/models/dream_entry.dart';
import '../../journal/models/follow_up_answers.dart';
import '../../journal/repositories/dream_repository.dart';
import '../../journal/repositories/follow_up_repository.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _dreamRepository = DreamRepository();
  final _followUpRepository = FollowUpRepository();
  final _associationController = TextEditingController();
  final _recentEventController = TextEditingController();
  final _hiddenFeelingController = TextEditingController();

  late Future<_InsightData> _insightsFuture;
  bool _strongImageFeelsImportant = false;
  bool _recentEventFeelsConnected = false;
  bool _repeatedFeelingFeelsImportant = false;
  String? _personalConclusion;

  @override
  void initState() {
    super.initState();
    _insightsFuture = _loadInsights();
  }

  Future<_InsightData> _loadInsights() async {
    final dreams = await _dreamRepository.getDreams();
    final answers = <FollowUpAnswers>[];

    for (final dream in dreams) {
      final dreamId = dream.id;
      if (dreamId == null) {
        continue;
      }
      final latestAnswers = await _followUpRepository.getLatestAnswersForDream(
        dreamId,
      );
      if (latestAnswers != null) {
        answers.add(latestAnswers);
      }
    }

    return _InsightData(dreams: dreams, answers: answers);
  }

  @override
  void dispose() {
    _associationController.dispose();
    _recentEventController.dispose();
    _hiddenFeelingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: FutureBuilder<_InsightData>(
        future: _insightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? const _InsightData();

          if (data.dreams.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Add and analyze a few dreams to see recurring symbols, emotional patterns, and reflection questions.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final symbols = _countSymbols(data.dreams);
          final emotions = _countAnswers(
            data.answers.map((answer) => answer.emotions),
          );
          final stressAverage = data.answers.isEmpty
              ? null
              : data.answers
                    .map((answer) => answer.stressLevel)
                    .reduce((first, second) => first + second) /
                data.answers.length;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _InsightCard(
                title: 'Recurring symbols',
                body: symbols.isEmpty
                    ? 'No repeated symbols yet. Add more dream details to build a clearer pattern.'
                    : _formatCounts(symbols),
              ),
              const SizedBox(height: 12),
              _InsightCard(
                title: 'Emotional patterns',
                body: emotions.isEmpty
                    ? 'No follow-up emotions saved yet.'
                    : _formatCounts(emotions),
              ),
              const SizedBox(height: 12),
              _InsightCard(
                title: 'Stress context',
                body: stressAverage == null
                    ? 'Stress data will appear after follow-up questions.'
                    : 'Average recorded stress: ${stressAverage.toStringAsFixed(1)}/10. Daily pressure can feed dream images, especially when similar emotions repeat.',
              ),
              const SizedBox(height: 12),
              _ReflectionQuestionsCard(
                strongestSymbol: _strongestSymbol(symbols),
                associationController: _associationController,
                recentEventController: _recentEventController,
                hiddenFeelingController: _hiddenFeelingController,
                strongImageFeelsImportant: _strongImageFeelsImportant,
                recentEventFeelsConnected: _recentEventFeelsConnected,
                repeatedFeelingFeelsImportant: _repeatedFeelingFeelsImportant,
                onStrongImageChanged: (value) {
                  setState(() => _strongImageFeelsImportant = value);
                },
                onRecentEventChanged: (value) {
                  setState(() => _recentEventFeelsConnected = value);
                },
                onRepeatedFeelingChanged: (value) {
                  setState(() => _repeatedFeelingFeelsImportant = value);
                },
                onGenerateConclusion: () {
                  setState(() {
                    _personalConclusion = _buildPersonalConclusion(
                      symbols,
                      emotions,
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              _InsightCard(
                title: 'Pattern note',
                body: _personalConclusion ?? _patternNote(symbols, emotions),
              ),
            ],
          );
        },
      ),
    );
  }

  Map<String, int> _countSymbols(List<DreamEntry> dreams) {
    final counts = <String, int>{};
    const keywords = [
      'water',
      'death',
      'died',
      'house',
      'home',
      'bridge',
      'school',
      'exam',
      'road',
      'door',
      'family',
      'mother',
      'father',
      'teacher',
      'falling',
      'running',
    ];

    for (final dream in dreams) {
      final text = dream.description.toLowerCase();
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          counts[keyword] = (counts[keyword] ?? 0) + 1;
        }
      }
    }

    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  Map<String, int> _countAnswers(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      final key = value.trim();
      if (key.isEmpty) {
        continue;
      }
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return Map.fromEntries(
      counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  String _formatCounts(Map<String, int> counts) {
    return counts.entries
        .take(5)
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
  }

  String _strongestSymbol(Map<String, int> symbols) {
    return symbols.isEmpty ? 'the strongest image' : symbols.keys.first;
  }

  String _patternNote(Map<String, int> symbols, Map<String, int> emotions) {
    final repeatedSymbols = symbols.entries.where((entry) => entry.value >= 2);
    final repeatedEmotions = emotions.entries.where(
      (entry) => entry.value >= 2,
    );

    if (repeatedSymbols.isEmpty && repeatedEmotions.isEmpty) {
      return 'No strong repeated pattern yet. Add more dreams and follow-up answers.';
    }

    final parts = <String>[];
    if (repeatedSymbols.isNotEmpty) {
      parts.add(
        'Am observat ca in mai multe vise apare simbolul ${repeatedSymbols.first.key}.',
      );
    }
    if (repeatedEmotions.isNotEmpty) {
      parts.add(
        'Emotia ${repeatedEmotions.first.key} se repeta si poate merita urmarita.',
      );
    }
    parts.add(
      'Acestea sunt puncte de pornire pentru asocieri personale, nu concluzii fixe.',
    );
    return parts.join(' ');
  }

  String _buildPersonalConclusion(
    Map<String, int> symbols,
    Map<String, int> emotions,
  ) {
    final strongestSymbol = _strongestSymbol(symbols);
    final strongestEmotion = emotions.isEmpty ? null : emotions.keys.first;
    final association = _associationController.text.trim();
    final recentEvent = _recentEventController.text.trim();
    final hiddenFeeling = _hiddenFeelingController.text.trim();

    final parts = <String>[];

    if (_strongImageFeelsImportant || association.isNotEmpty) {
      parts.add(
        'Imaginea "$strongestSymbol" pare importanta pentru tine'
        '${association.isEmpty ? '' : ' si o asociezi cu "$association"'}',
      );
    }

    if (_recentEventFeelsConnected || recentEvent.isNotEmpty) {
      parts.add(
        'visul poate avea legatura cu ceva recent'
        '${recentEvent.isEmpty ? '' : ': "$recentEvent"'}',
      );
    }

    if (_repeatedFeelingFeelsImportant || hiddenFeeling.isNotEmpty) {
      parts.add(
        'emotia repetata merita observata'
        '${strongestEmotion == null ? '' : ' mai ales zona de "$strongestEmotion"'}'
        '${hiddenFeeling.isEmpty ? '' : ', posibil legata de "$hiddenFeeling"'}',
      );
    }

    if (parts.isEmpty) {
      return 'Nu ai marcat inca o legatura clara. Raspunde la cel putin o intrebare sau bifeaza ce pare relevant, apoi genereaza din nou concluzia.';
    }

    return 'Concluzie personala: ${parts.join(', ')}. Nu este o interpretare fixa, ci o ipoteza de reflectie pe care o poti compara cu visele urmatoare.';
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}

class _ReflectionQuestionsCard extends StatelessWidget {
  const _ReflectionQuestionsCard({
    required this.strongestSymbol,
    required this.associationController,
    required this.recentEventController,
    required this.hiddenFeelingController,
    required this.strongImageFeelsImportant,
    required this.recentEventFeelsConnected,
    required this.repeatedFeelingFeelsImportant,
    required this.onStrongImageChanged,
    required this.onRecentEventChanged,
    required this.onRepeatedFeelingChanged,
    required this.onGenerateConclusion,
  });

  final String strongestSymbol;
  final TextEditingController associationController;
  final TextEditingController recentEventController;
  final TextEditingController hiddenFeelingController;
  final bool strongImageFeelsImportant;
  final bool recentEventFeelsConnected;
  final bool repeatedFeelingFeelsImportant;
  final ValueChanged<bool> onStrongImageChanged;
  final ValueChanged<bool> onRecentEventChanged;
  final ValueChanged<bool> onRepeatedFeelingChanged;
  final VoidCallback onGenerateConclusion;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection questions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('The image "$strongestSymbol" feels important.'),
              value: strongImageFeelsImportant,
              onChanged: (value) => onStrongImageChanged(value ?? false),
            ),
            TextField(
              controller: associationController,
              decoration: InputDecoration(
                labelText: 'What does "$strongestSymbol" remind you of?',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('A recent event feels connected to this.'),
              value: recentEventFeelsConnected,
              onChanged: (value) => onRecentEventChanged(value ?? false),
            ),
            TextField(
              controller: recentEventController,
              decoration: const InputDecoration(
                labelText: 'What recent event might connect?',
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('A repeated feeling feels important.'),
              value: repeatedFeelingFeelsImportant,
              onChanged: (value) => onRepeatedFeelingChanged(value ?? false),
            ),
            TextField(
              controller: hiddenFeelingController,
              decoration: const InputDecoration(
                labelText: 'What feeling could be underneath?',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onGenerateConclusion,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate conclusion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightData {
  const _InsightData({
    this.dreams = const [],
    this.answers = const [],
  });

  final List<DreamEntry> dreams;
  final List<FollowUpAnswers> answers;
}
