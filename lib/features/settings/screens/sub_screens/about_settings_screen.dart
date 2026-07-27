import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class AboutSettingsScreen extends StatelessWidget {
  const AboutSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('About System')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
                      child: const Icon(Icons.local_hospital, size: 40, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      settings.translate('About Lumina Clinic Manager'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.translate('Clinic Management System'),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    _buildInfoRow(settings.translate('Application Version'), settings.translate('Version 1.0.0 (Build 2026)')),
                    const SizedBox(height: 12),
                    _buildInfoRow(settings.translate('Database Schema Version'), settings.translate('SQLite Database Schema v6')),
                    const SizedBox(height: 12),
                    _buildInfoRow(settings.translate('UI Framework'), 'Flutter Material 3 Architecture'),
                    const SizedBox(height: 12),
                    _buildInfoRow(settings.translate('Repository'), 'GitHub: Xlr8iq/Project-L'),
                    const SizedBox(height: 12),
                    _buildInfoRow(settings.translate('Status'), settings.translate('All systems operational.')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
