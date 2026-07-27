import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class WhatsappSettingsScreen extends StatefulWidget {
  const WhatsappSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WhatsappSettingsScreen> createState() => _WhatsappSettingsScreenState();
}

class _WhatsappSettingsScreenState extends State<WhatsappSettingsScreen> {
  late TextEditingController _numberController;
  late TextEditingController _reminderController;
  late TextEditingController _confirmationController;
  late TextEditingController _cancellationController;
  late TextEditingController _recallController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _numberController = TextEditingController(text: provider.whatsappNumber);
    _reminderController = TextEditingController(text: provider.whatsappReminderTemplate);
    _confirmationController = TextEditingController(text: provider.whatsappConfirmationTemplate);
    _cancellationController = TextEditingController(text: provider.whatsappCancellationTemplate);
    _recallController = TextEditingController(text: provider.whatsappRecallTemplate);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _reminderController.dispose();
    _confirmationController.dispose();
    _cancellationController.dispose();
    _recallController.dispose();
    super.dispose();
  }

  void _saveWhatsappSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    provider.updateSettings({
      'whatsapp_number': _numberController.text.trim(),
      'whatsapp_reminder': _reminderController.text.trim(),
      'whatsapp_confirmation': _confirmationController.text.trim(),
      'whatsapp_cancellation': _cancellationController.text.trim(),
      'whatsapp_recall': _recallController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.translate('WhatsApp settings saved!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.translate('WhatsApp & Reminders')),
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
                        Icon(Icons.chat_bubble_outline, color: Colors.green, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'WhatsApp & Automated Reminders',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.translate('Configure templates used for sending WhatsApp messages to patients.'),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Clinic WhatsApp Number'),
                        prefixIcon: const Icon(Icons.phone_android),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      provider.translate('Message Templates ({patient}, {date}, {time})'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _reminderController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Appointment Reminder Template'),
                        prefixIcon: const Icon(Icons.notifications_active),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _confirmationController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Appointment Confirmation Template'),
                        prefixIcon: const Icon(Icons.check_circle_outline),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _cancellationController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Cancellation Notice Template'),
                        prefixIcon: const Icon(Icons.cancel_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _recallController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Recall / 6-Month Checkup Template'),
                        prefixIcon: const Icon(Icons.event_repeat),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _saveWhatsappSettings,
                        child: Text(provider.translate('Save WhatsApp Templates')),
                      ),
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
