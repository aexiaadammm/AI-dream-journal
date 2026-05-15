import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _nationalities = [
    'Romanian',
    'Hungarian',
    'German',
    'French',
    'Italian',
    'Spanish',
    'British',
    'American',
    'Ukrainian',
    'Turkish',
    'Other',
    'Prefer not to say',
  ];

  static const _culturalBackgrounds = [
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
    'Prefer not to say',
  ];

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _professionController = TextEditingController();
  final _profileRepository = UserProfileRepository();

  String? _selectedNationality;
  String? _selectedCulture;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    if (_selectedNationality == null || _selectedCulture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose nationality and culture.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    await _profileRepository.saveProfile(
      UserProfile(
        name: _nameController.text.trim().isEmpty
            ? 'Dreamer'
            : _nameController.text.trim(),
        age: _ageController.text.trim().isEmpty
            ? 'Prefer not to say'
            : _ageController.text.trim(),
        nationality: _selectedNationality!,
        culturalBackground: _selectedCulture!,
        professionOrInterest: _professionController.text.trim().isEmpty
            ? 'General creativity'
            : _professionController.text.trim(),
        updatedAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.journal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Text(
              'Dream Journal',
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'A calm place to record dreams, reflect on patterns, and receive gentle wellness guidance.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: 'Name',
              hint: 'How should we call you?',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Age',
              hint: 'For age-aware personalization later',
              keyboardType: TextInputType.number,
              controller: _ageController,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedNationality,
              decoration: const InputDecoration(
                labelText: 'Nationality',
                helperText: 'Used later for culturally aware reflections.',
              ),
              items: _nationalities
                  .map(
                    (nationality) => DropdownMenuItem(
                      value: nationality,
                      child: Text(nationality),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedNationality = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCulture,
              decoration: const InputDecoration(
                labelText: 'Cultural background',
                helperText: 'Choose the context that feels closest to you.',
              ),
              items: _culturalBackgrounds
                  .map(
                    (culture) =>
                        DropdownMenuItem(value: culture, child: Text(culture)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCulture = value);
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Profession or field of interest',
              hint: 'Teacher, design, engineering, writing, business...',
              controller: _professionController,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: _isSaving ? 'Saving...' : 'Continue to journal',
              icon: Icons.arrow_forward,
              onPressed: _isSaving ? null : _saveAndContinue,
            ),
          ],
        ),
      ),
    );
  }
}
