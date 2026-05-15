import 'package:flutter/material.dart';

import '../../features/assistant/screens/assistant_screen.dart';
import '../../features/ai_analysis/screens/dream_analysis_screen.dart';
import '../../features/insights/screens/insights_screen.dart';
import '../../features/journal/screens/add_dream_screen.dart';
import '../../features/journal/screens/follow_up_questions_screen.dart';
import '../../features/journal/screens/journal_home_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import 'app_routes.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => switch (settings.name) {
        AppRoutes.onboarding => const ProfileSetupScreen(),
        AppRoutes.journal => const JournalHomeScreen(),
        AppRoutes.addDream => const AddDreamScreen(),
        AppRoutes.followUpQuestions => FollowUpQuestionsScreen.fromSettings(
          settings,
        ),
        AppRoutes.dreamAnalysis => DreamAnalysisScreen.fromSettings(settings),
        AppRoutes.insights => const InsightsScreen(),
        AppRoutes.assistant => const AssistantScreen(),
        AppRoutes.settings => const SettingsScreen(),
        _ => const ProfileSetupScreen(),
      },
    );
  }
}
