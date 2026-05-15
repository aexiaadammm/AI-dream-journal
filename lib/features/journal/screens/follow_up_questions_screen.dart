import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../ai_analysis/models/ai_request.dart';
import '../models/dream_entry.dart';
import '../models/follow_up_answers.dart';
import '../repositories/follow_up_repository.dart';

class FollowUpQuestionsScreen extends StatefulWidget {
  const FollowUpQuestionsScreen({super.key, required this.dream});

  final DreamEntry dream;

  static Widget fromSettings(RouteSettings settings) {
    final dream = settings.arguments;

    if (dream is DreamEntry) {
      return FollowUpQuestionsScreen(dream: dream);
    }

    return const _MissingDreamScreen();
  }

  @override
  State<FollowUpQuestionsScreen> createState() =>
      _FollowUpQuestionsScreenState();
}

class _FollowUpQuestionsScreenState extends State<FollowUpQuestionsScreen> {
  static const _emotionOptions = [
    'Calm',
    'Fear',
    'Joy',
    'Confusion',
    'Sadness',
    'Relief',
    'Curiosity',
  ];

  static const _sleepQualityOptions = [
    'Restful',
    'Interrupted',
    'Light sleep',
    'Heavy sleep',
    'Poor sleep',
  ];

  static const _beliefOptions = [
    'Psychological',
    'Spiritual',
    'Religious',
    'Symbolic',
    'Skeptical',
    'Not sure',
  ];

  static const _culturalOptions = [
    'Eastern European',
    'Western European',
    'Balkan',
    'Mediterranean',
    'Middle Eastern',
    'North American',
    'Latin American',
    'Asian',
    'African',
    'Mixed cultural background',
    'Other',
  ];

  final _recentEventsController = TextEditingController();
  final _followUpRepository = FollowUpRepository();

  String? _selectedEmotion;
  String? _selectedSleepQuality;
  String? _selectedBeliefs;
  String? _selectedCulture;
  double _stressLevel = 4;
  bool _isRecurring = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _recentEventsController.dispose();
    super.dispose();
  }

  Future<void> _saveAndAnalyze() async {
    if (_selectedEmotion == null ||
        _selectedSleepQuality == null ||
        _selectedBeliefs == null ||
        _selectedCulture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the dropdown questions.')),
      );
      return;
    }

    final dreamId = widget.dream.id;
    if (dreamId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The dream must be saved first.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final answers = FollowUpAnswers(
      dreamId: dreamId,
      emotions: _selectedEmotion!,
      stressLevel: _stressLevel.round(),
      sleepQuality: _selectedSleepQuality!,
      beliefs: _selectedBeliefs!,
      culturalBackground: _selectedCulture!,
      recentLifeEvents: _recentEventsController.text.trim().isEmpty
          ? 'No recent events added.'
          : _recentEventsController.text.trim(),
      isRecurring: _isRecurring,
      createdAt: DateTime.now(),
    );

    try {
      await _followUpRepository.saveAnswers(answers);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.dreamAnalysis,
        arguments: AIRequest(dream: widget.dream, followUpAnswers: answers),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the follow-up answers.')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-up Questions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            widget.dream.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'A few details help the mocked analysis feel more personal.',
          ),
          const SizedBox(height: 24),
          _DropdownQuestion(
            label: 'Main emotion',
            value: _selectedEmotion,
            items: _emotionOptions,
            onChanged: (value) => setState(() => _selectedEmotion = value),
          ),
          const SizedBox(height: 16),
          Text('Stress level: ${_stressLevel.round()}/10'),
          Slider(
            value: _stressLevel,
            min: 0,
            max: 10,
            divisions: 10,
            label: _stressLevel.round().toString(),
            onChanged: (value) => setState(() => _stressLevel = value),
          ),
          const SizedBox(height: 16),
          _DropdownQuestion(
            label: 'Sleep quality',
            value: _selectedSleepQuality,
            items: _sleepQualityOptions,
            onChanged: (value) => setState(() => _selectedSleepQuality = value),
          ),
          const SizedBox(height: 16),
          _DropdownQuestion(
            label: 'Belief lens',
            value: _selectedBeliefs,
            items: _beliefOptions,
            onChanged: (value) => setState(() => _selectedBeliefs = value),
          ),
          const SizedBox(height: 16),
          _DropdownQuestion(
            label: 'Cultural background',
            value: _selectedCulture,
            items: _culturalOptions,
            onChanged: (value) => setState(() => _selectedCulture = value),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Recent life events',
            hint: 'Stress, changes, relationships, work, school...',
            maxLines: 4,
            controller: _recentEventsController,
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Is this dream recurring?'),
            value: _isRecurring,
            onChanged: (value) => setState(() => _isRecurring = value),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _isSaving ? 'Creating analysis...' : 'Save and analyze',
            icon: Icons.auto_awesome,
            onPressed: _isSaving ? null : _saveAndAnalyze,
          ),
        ],
      ),
    );
  }
}

class _DropdownQuestion extends StatelessWidget {
  const _DropdownQuestion({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _MissingDreamScreen extends StatelessWidget {
  const _MissingDreamScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow-up Questions')),
      body: const Center(
        child: Text('No saved dream was provided for follow-up questions.'),
      ),
    );
  }
}
