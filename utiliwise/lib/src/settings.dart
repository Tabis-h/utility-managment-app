import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white, // Match home page background
        appBar: AppBar(
        title: const Text('Settings'),
    iconTheme: const IconThemeData(color: Colors.black54), // Subtle icon color
    ),
    body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
    _buildSettingsTile(
    icon: Icons.notifications,
    title: 'Notifications',
    subtitle: 'Manage notification preferences',
    ),
        _buildSettingsTile(
          icon: Icons.lock,
          title: 'Privacy',
          subtitle: 'Control your privacy settings',
        ),
        _buildSettingsTile(
          icon: Icons.help,
          title: 'Help & Support',
          subtitle: 'Get help or contact support',
        ),
        _buildSettingsTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'App information and version',
        ),
      ],
    ));
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Handle settings navigation
        },
      ),
    );
  }
}