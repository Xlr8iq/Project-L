import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class SupportSettingsScreen extends StatelessWidget {
  const SupportSettingsScreen({Key? key}) : super(key: key);

  void _showFeedbackDialog(BuildContext context, String typeKey) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.translate(typeKey)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(settings.translate('Need help? Contact support or submit feedback.')),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              decoration: InputDecoration(hintText: settings.translate('Send Feedback')),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(settings.translate('Cancel'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(settings.translate('Send Feedback')),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(settings.translate('Save')),
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
        title: Text(settings.translate('Support & Developer')),
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
                        const Icon(Icons.help_outline, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          settings.translate('Support & Technical Assistance'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
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
                      title: Text(settings.translate('Contact Support'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('support@lumina-dental.com • GitHub: @Xlr8iq'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Contact Support'),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),

                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.shade100,
                        child: const Icon(Icons.bug_report, color: Colors.red),
                      ),
                      title: Text(settings.translate('Report a Bug'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(settings.translate('Technical assistance, bug reports, and feedback')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Report a Bug'),
                    ),
                    const Divider(height: 1, color: AppTheme.borderLight),

                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade100,
                        child: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      ),
                      title: Text(settings.translate('Request a Feature'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(settings.translate('Contact support, report bugs & request features')),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _showFeedbackDialog(context, 'Request a Feature'),
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
