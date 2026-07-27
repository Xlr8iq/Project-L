import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class SupportSettingsScreen extends StatelessWidget {
  const SupportSettingsScreen({Key? key}) : super(key: key);

  void _showFeedbackDialog(BuildContext context, String type) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send $type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Describe your $type in detail:'),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              decoration: const InputDecoration(hintText: 'Type message here...'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$type submitted! Thank you.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('Support & Feedback')),
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
                        Icon(Icons.help_outline, color: AppTheme.primaryBlue, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Help, Support & Feedback',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: Icon(Icons.code, color: Colors.white),
                      ),
                      title: const Text('Contact Developer', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Support Email: support@lumina-dental.com • GitHub: @Xlr8iq'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Support Inquiry'),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),

                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(Icons.bug_report, color: Colors.red),
                      ),
                      title: const Text('Report Bug', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Encountered an issue? Submit a bug report directly.'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Bug Report'),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),

                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade100,
                        child: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      ),
                      title: const Text('Request Feature', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Suggest new capabilities or clinical workflow enhancements.'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Feature Request'),
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
