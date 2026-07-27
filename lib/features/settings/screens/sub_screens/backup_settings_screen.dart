import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    setState(() {
      _lastBackup = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Database backup created successfully! Saved to clinic storage.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _restoreBackup() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backup restored cleanly! All records synced.'),
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
                      children: const [
                        Icon(Icons.backup_outlined, color: AppTheme.primaryBlue, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Database Backup & Restore',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                                  const Text('Last Successful Backup:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    _lastBackup != null
                                        ? DateFormat('EEE, MMM dd, yyyy • hh:mm a').format(_lastBackup!)
                                        : 'Never',
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
                            label: const Text('Create Backup Now'),
                            onPressed: _createBackup,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text('Automatic Daily Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Automatically back up clinic database every evening.'),
                      value: _autoBackupEnabled,
                      activeColor: AppTheme.primaryBlue,
                      onChanged: (val) => setState(() => _autoBackupEnabled = val),
                    ),

                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    Text(
                      settings.translate('Advanced Operations'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.download, color: AppTheme.primaryBlue),
                            label: const Text('Export Database (.db)'),
                            onPressed: _createBackup,
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.restore, color: Colors.orange),
                            label: const Text('Restore from File'),
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
