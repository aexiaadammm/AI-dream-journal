import 'package:flutter/material.dart';

import '../../../core/routing/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/dream_entry.dart';
import '../repositories/dream_repository.dart';

class JournalHomeScreen extends StatefulWidget {
  const JournalHomeScreen({super.key});

  @override
  State<JournalHomeScreen> createState() => _JournalHomeScreenState();
}

class _JournalHomeScreenState extends State<JournalHomeScreen> {
  final _dreamRepository = DreamRepository();
  late Future<List<DreamEntry>> _dreamsFuture;

  @override
  void initState() {
    super.initState();
    _dreamsFuture = _dreamRepository.getDreams();
  }

  void _refreshDreams() {
    setState(() {
      _dreamsFuture = _dreamRepository.getDreams();
    });
  }

  Future<void> _openAddDream() async {
    final saved = await Navigator.of(context).pushNamed(AppRoutes.addDream);

    if (saved == true) {
      _refreshDreams();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Capture what you remember. The analysis and pattern detection will arrive in later phases.',
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Add dream',
                    icon: Icons.add,
                    onPressed: _openAddDream,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<DreamEntry>>(
            future: _dreamsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final dreams = snapshot.data ?? [];

              if (dreams.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'No dreams saved yet. Add your first dream when you are ready.',
                    ),
                  ),
                );
              }

              return Column(
                children: dreams
                    .map(
                      (dream) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DreamTile(dream: dream),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
          _NavigationTile(
            icon: Icons.insights_outlined,
            title: 'Insights',
            subtitle: 'Future emotional and symbolic patterns',
            routeName: AppRoutes.insights,
          ),
          const SizedBox(height: 12),
          _NavigationTile(
            icon: Icons.self_improvement_outlined,
            title: 'Assistant',
            subtitle: 'Future daily advice and reflective check-ins',
            routeName: AppRoutes.assistant,
          ),
        ],
      ),
    );
  }
}

class _DreamTile extends StatelessWidget {
  const _DreamTile({required this.dream});

  final DreamEntry dream;

  @override
  Widget build(BuildContext context) {
    final createdAt = dream.createdAt;
    final dateLabel = '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.nightlight_round,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        title: Text(dream.title),
        subtitle: Text('$dateLabel - Mood: ${dream.mood}'),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(routeName),
      ),
    );
  }
}
