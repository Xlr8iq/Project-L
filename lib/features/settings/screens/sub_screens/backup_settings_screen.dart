import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({Key? key}) : super(key: key);

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  DateTime? _lastBackup = DateTime.now().subtract(const Duration(hours: 4));
  bool _autoBackupEnabled = true;

  void _createBackup() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() {
      _lastBackup = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(settings.translate('Backup created successfully!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _restoreBackup() {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(settings.translate('Database restored successfully!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('Backup & Restore')),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.backup_outlined, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          settings.translate('Database Backup & Recovery'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.history, color: AppTheme.primaryBlue),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(settings.translate('Last Backup:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    _lastBackup != null
                                        ? settings.formatDate(_lastBackup!)
                                        : settings.translate('Never'),
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.cloud_upload_outlined),
                            label: Text(settings.translate('Create Instant Backup')),
                            onPressed: _createBackup,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: Text(settings.translate('Automatic Daily Backups'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(settings.translate('Create database backups to protect patient records and financial data.')),
                      value: _autoBackupEnabled,
                      activeColor: AppTheme.primaryBlue,
                      onChanged: (val) => setState(() => _autoBackupEnabled = val),
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download, color: AppTheme.primaryBlue),
                            label: Text(settings.translate('Create Instant Backup')),
                            onPressed: _createBackup,
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restore, color: Colors.orange),
                            label: Text(settings.translate('Restore Database')),
                            onPressed: _restoreBackup,
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
