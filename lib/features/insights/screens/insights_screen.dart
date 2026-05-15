import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _InsightCard(
            title: 'Recurring symbols',
            body: 'Symbol tracking will appear here after dream entries exist.',
          ),
          SizedBox(height: 12),
          _InsightCard(
            title: 'Emotional patterns',
            body:
                'Mood trends and repeated emotional tones will be added later.',
          ),
          SizedBox(height: 12),
          _InsightCard(
            title: 'Context-aware reflections',
            body:
                'Future insights can consider culture, beliefs, and life context.',
          ),
        ],
      ),
    );
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
