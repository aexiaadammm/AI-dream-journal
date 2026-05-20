import 'package:flutter/material.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../journal/models/dream_entry.dart';
import '../../journal/models/follow_up_answers.dart';
import '../../journal/repositories/dream_repository.dart';
import '../../journal/repositories/follow_up_repository.dart';
import '../../onboarding/models/user_profile.dart';
import '../../onboarding/repositories/user_profile_repository.dart';
import '../models/assistant_context.dart';
import '../models/assistant_message.dart';
import '../models/assistant_mode.dart';
import '../services/assistant_api_service.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _dreamRepository = DreamRepository();
  final _followUpRepository = FollowUpRepository();
  final _profileRepository = UserProfileRepository();
  final _assistantService = const AssistantApiService();
  final _messageController = TextEditingController();

  late Future<_AssistantData> _assistantDataFuture;
  AssistantMode _mode = AssistantMode.reflection;
  DreamEntry? _selectedDream;
  FollowUpAnswers? _selectedAnswers;
  bool _isSending = false;

  final List<AssistantMessage> _messages = const [
    AssistantMessage(
      text:
          'Choose a saved dream, select a mode, and ask how it could support reflection or creative action.',
      isUser: false,
    ),
  ].toList();

  @override
  void initState() {
    super.initState();
    _assistantDataFuture = _loadAssistantData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<_AssistantData> _loadAssistantData() async {
    final dreams = await _dreamRepository.getDreams();
    final profile = await _profileRepository.getProfile();

    if (dreams.isNotEmpty) {
      _selectedDream = dreams.first;
      _selectedAnswers = await _followUpRepository.getLatestAnswersForDream(
        dreams.first.id!,
      );
    }

    return _AssistantData(dreams: dreams, profile: profile);
  }

  Future<void> _selectDream(DreamEntry? dream) async {
    if (dream == null) {
      return;
    }

    final answers = dream.id == null
        ? null
        : await _followUpRepository.getLatestAnswersForDream(dream.id!);

    setState(() {
      _selectedDream = dream;
      _selectedAnswers = answers;
      _messages.add(
        AssistantMessage(
          text: 'Dream selected: ${dream.title}',
          isUser: false,
        ),
      );
    });
  }

  Future<void> _sendMessage(UserProfile? profile) async {
    final text = _messageController.text.trim();
    final dream = _selectedDream;

    if (text.isEmpty || dream == null) {
      return;
    }

    setState(() {
      _isSending = true;
      _messageController.clear();
      _messages.add(AssistantMessage(text: text, isUser: true));
    });

    try {
      final reply = await _assistantService.reply(
        context: AssistantContext(
          mode: _mode,
          dream: dream,
          followUpAnswers: _selectedAnswers,
          userProfile: profile,
        ),
        userMessage: text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(AssistantMessage(text: reply, isUser: false));
        _isSending = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          const AssistantMessage(
            text:
                'I could not reach the AI assistant. Please check that the backend is running and the OpenAI API key is set.',
            isUser: false,
          ),
        );
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant')),
      body: FutureBuilder<_AssistantData>(
        future: _assistantDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? const _AssistantData();

          if (data.dreams.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Add and analyze a dream first, then return here for assistant conversation.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Column(
                  children: [
                    DropdownButtonFormField<DreamEntry>(
                      value: _selectedDream,
                      decoration: const InputDecoration(
                        labelText: 'Saved dream',
                      ),
                      items: data.dreams
                          .map(
                            (dream) => DropdownMenuItem(
                              value: dream,
                              child: Text(dream.title),
                            ),
                          )
                          .toList(),
                      onChanged: _selectDream,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AssistantMode>(
                      value: _mode,
                      decoration: const InputDecoration(
                        labelText: 'Assistant mode',
                      ),
                      items: AssistantMode.values
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode.label),
                            ),
                          )
                          .toList(),
                      onChanged: (mode) {
                        if (mode == null) {
                          return;
                        }
                        setState(() => _mode = mode);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _ChatBubble(message: _messages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    AppTextField(
                      label: _mode == AssistantMode.creativeTransformation
                          ? 'Ask for a practical creative idea'
                          : 'Ask for reflection',
                      hint: 'How can I use this dream today?',
                      controller: _messageController,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: _isSending ? 'Thinking...' : 'Send',
                      icon: Icons.send,
                      onPressed:
                          _isSending ? null : () => _sendMessage(data.profile),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surface;
    final textColor =
        message.isUser ? Colors.white : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(message.text, style: TextStyle(color: textColor)),
          ),
        ),
      ),
    );
  }
}

class _AssistantData {
  const _AssistantData({
    this.dreams = const [],
    this.profile,
  });

  final List<DreamEntry> dreams;
  final UserProfile? profile;
}
