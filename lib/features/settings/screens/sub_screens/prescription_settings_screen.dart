import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class PrescriptionSettingsScreen extends StatefulWidget {
  const PrescriptionSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrescriptionSettingsScreen> createState() => _PrescriptionSettingsScreenState();
}

class _PrescriptionSettingsScreenState extends State<PrescriptionSettingsScreen> {
  late TextEditingController _headerController;
  late TextEditingController _footerController;
  late TextEditingController _signatureController;
  late TextEditingController _contactController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _headerController = TextEditingController(text: provider.rxHeader);
    _footerController = TextEditingController(text: provider.rxFooter);
    _signatureController = TextEditingController(text: provider.rxSignature);
    _contactController = TextEditingController(text: provider.rxContactInfo);
    _notesController = TextEditingController(text: provider.rxNotes);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    _signatureController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _savePrescriptionSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    provider.updateSettings({
      'rx_header': _headerController.text.trim(),
      'rx_footer': _footerController.text.trim(),
      'rx_signature': _signatureController.text.trim(),
      'rx_contact_info': _contactController.text.trim(),
      'rx_notes': _notesController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.translate('Prescription settings updated!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.translate('Prescription Settings')),
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
                        const Icon(Icons.description_outlined, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          provider.translate('Prescription Settings'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.translate('Header branding, footers, signature & notes'),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _headerController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Header Text'),
                        prefixIcon: const Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _signatureController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Doctor Stamp / Signature'),
                        prefixIcon: const Icon(Icons.draw),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _contactController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Contact Info Line'),
                        prefixIcon: const Icon(Icons.contact_mail_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Default Instructions / Notes'),
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _footerController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Footer Text'),
                        prefixIcon: const Icon(Icons.short_text),
                      ),
                      maxLines: 2,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _savePrescriptionSettings,
                        child: Text(provider.translate('Save Prescription Settings')),
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
