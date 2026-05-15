import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('shows onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const DreamJournalApp());

    expect(find.text('Dream Journal'), findsOneWidget);
    expect(find.text('Continue to journal'), findsOneWidget);
  });
}
