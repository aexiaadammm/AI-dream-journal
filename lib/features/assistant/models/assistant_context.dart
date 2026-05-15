import '../../journal/models/dream_entry.dart';
import '../../journal/models/follow_up_answers.dart';
import '../../onboarding/models/user_profile.dart';
import 'assistant_mode.dart';

class AssistantContext {
  const AssistantContext({
    required this.mode,
    required this.dream,
    required this.followUpAnswers,
    required this.userProfile,
  });

  final AssistantMode mode;
  final DreamEntry dream;
  final FollowUpAnswers? followUpAnswers;
  final UserProfile? userProfile;
}
