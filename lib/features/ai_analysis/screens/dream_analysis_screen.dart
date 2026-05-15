import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import '../services/ai_analysis_service.dart';

class DreamAnalysisScreen extends StatefulWidget {
  const DreamAnalysisScreen({super.key, required this.request});

  final AIRequest request;

  static Widget fromSettings(RouteSettings settings) {
    final request = settings.arguments;

    if (request is AIRequest) {
      return DreamAnalysisScreen(request: request);
    }

    return const _MissingAnalysisScreen();
  }

  @override
  State<DreamAnalysisScreen> createState() => _DreamAnalysisScreenState();
}

class _DreamAnalysisScreenState extends State<DreamAnalysisScreen> {
  final _analysisService = const AIAnalysisService();
  late Future<AIResponse> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = _analysisService.analyzeDream(widget.request);
  }

  void _retryAnalysis() {
    setState(() {
      _analysisFuture = _analysisService.analyzeDream(widget.request);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dream Analysis')),
      body: FutureBuilder<AIResponse>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _AnalysisLoadingView();
          }

          if (snapshot.hasError) {
            return _AnalysisErrorView(onRetry: _retryAnalysis);
          }

          final analysis = snapshot.data;
          if (analysis == null) {
            return _AnalysisErrorView(onRetry: _retryAnalysis);
          }

          return _AnalysisResultView(analysis: analysis);
        },
      ),
    );
  }
}

class _AnalysisResultView extends StatelessWidget {
  const _AnalysisResultView({required this.analysis});

  final AIResponse analysis;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _AnalysisCard(
          title: 'Emotional tone',
          child: Text(analysis.emotionalTone),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Possible symbols',
          child: _BulletList(items: analysis.possibleSymbols),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Cultural and contextual interpretation',
          child: Text(analysis.contextualInterpretation),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Reflection questions',
          child: _BulletList(items: analysis.reflectionQuestions),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Key findings on dream types',
          child: _BulletList(items: analysis.dreamTypeFindings),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(
          title: 'Gentle daily advice',
          child: Text(analysis.dailyAdvice),
        ),
        const SizedBox(height: 12),
        _AnalysisCard(title: 'Disclaimer', child: Text(analysis.disclaimer)),
        const SizedBox(height: 24),
        AppButton(
          label: 'Back to journal',
          icon: Icons.arrow_back,
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.journal, (route) => false);
          },
        ),
      ],
    );
  }
}

class _AnalysisLoadingView extends StatelessWidget {
  const _AnalysisLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Creating a reflective analysis...'),
        ],
      ),
    );
  }
}

class _AnalysisErrorView extends StatelessWidget {
  const _AnalysisErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 36,
                ),
                const SizedBox(height: 12),
                Text(
                  'Analysis could not be created',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Try again, or return to the journal. In the future this state will also handle backend/API failures.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                AppButton(
                  label: 'Try again',
                  icon: Icons.refresh,
                  onPressed: onRetry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('- $item'),
            ),
          )
          .toList(),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MissingAnalysisScreen extends StatelessWidget {
  const _MissingAnalysisScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dream Analysis')),
      body: const Center(child: Text('No analysis request was provided.')),
    );
  }
}
