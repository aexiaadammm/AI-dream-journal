import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Profile'),
              subtitle: Text('Account details will be added in a later phase.'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Privacy'),
              subtitle: Text(
                'Data controls and consent settings coming later.',
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.health_and_safety_outlined),
              title: Text('Wellness disclaimer'),
              subtitle: Text('This app is reflective support, not diagnosis.'),
            ),
          ),
        ],
      ),
    );
  }
}
