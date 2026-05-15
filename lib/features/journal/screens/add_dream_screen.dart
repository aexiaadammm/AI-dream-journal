import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/dream_entry.dart';
import '../repositories/dream_repository.dart';

class AddDreamScreen extends StatefulWidget {
  const AddDreamScreen({super.key});

  @override
  State<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends State<AddDreamScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moodController = TextEditingController();
  final _dreamRepository = DreamRepository();

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _saveDream() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final mood = _moodController.text.trim();

    if (title.isEmpty || description.isEmpty || mood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all dream fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dream = DreamEntry(
        title: title,
        description: description,
        mood: mood,
        createdAt: DateTime.now(),
      );

      final dreamId = await _dreamRepository.addDream(dream);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.followUpQuestions,
        arguments: DreamEntry(
          id: dreamId,
          title: dream.title,
          description: dream.description,
          mood: dream.mood,
          createdAt: dream.createdAt,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the dream yet.')),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Dream')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppTextField(
            label: 'Dream title',
            hint: 'A short name for the dream',
            controller: _titleController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Dream entry',
            hint: 'Write everything you remember...',
            maxLines: 8,
            controller: _descriptionController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Mood on waking',
            hint: 'Calm, afraid, curious, relieved...',
            controller: _moodController,
          ),
          const SizedBox(height: 28),
          AppButton(
            label: _isSaving ? 'Saving...' : 'Save dream',
            icon: Icons.check,
            onPressed: _isSaving ? null : _saveDream,
          ),
        ],
      ),
    );
  }
}
