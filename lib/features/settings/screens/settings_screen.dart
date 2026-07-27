import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../dashboard/providers/settings_provider.dart';
import 'sub_screens/clinic_settings_screen.dart';
import 'sub_screens/prescription_settings_screen.dart';
import 'sub_screens/staff_settings_screen.dart';
import 'sub_screens/procedures_settings_screen.dart';
import 'sub_screens/financial_settings_screen.dart';
import 'sub_screens/whatsapp_settings_screen.dart';
import 'sub_screens/backup_settings_screen.dart';
import 'sub_screens/support_settings_screen.dart';
import 'sub_screens/about_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    final List<Map<String, dynamic>> sections = [
      {
        'title': settings.translate('Clinic Information'),
        'subtitle': settings.translate('Clinic name, logo, contact, language & currency'),
        'icon': Icons.local_hospital,
        'color': AppTheme.primaryBlue,
        'screen': const ClinicSettingsScreen(),
      },
      {
        'title': settings.translate('Prescription Settings'),
        'subtitle': settings.translate('Header branding, footers, signature & notes'),
        'icon': Icons.description_outlined,
        'color': Colors.indigo,
        'screen': const PrescriptionSettingsScreen(),
      },
      {
        'title': settings.translate('Staff Management'),
        'subtitle': settings.translate('Doctors & Secretaries credentials & active roles'),
        'icon': Icons.people_outline,
        'color': Colors.teal,
        'screen': const StaffSettingsScreen(),
      },
      {
        'title': settings.translate('Procedures & Fees'),
        'subtitle': settings.translate('Default fees, currency & planned visits counter'),
        'icon': Icons.medical_services_outlined,
        'color': Colors.deepOrange,
        'screen': const ProceduresSettingsScreen(),
      },
      {
        'title': settings.translate('Financial & Billing'),
        'subtitle': settings.translate('Default consultation fee & active payment methods'),
        'icon': Icons.account_balance_wallet_outlined,
        'color': Colors.green.shade700,
        'screen': const FinancialSettingsScreen(),
      },
      {
        'title': settings.translate('WhatsApp & Reminders'),
        'subtitle': settings.translate('Automated reminder templates & WhatsApp number'),
        'icon': Icons.chat_bubble_outline,
        'color': Colors.lightGreen.shade700,
        'screen': const WhatsappSettingsScreen(),
      },
      {
        'title': settings.translate('Backup & Restore'),
        'subtitle': settings.translate('Database export, automatic backups & restore points'),
        'icon': Icons.backup_outlined,
        'color': Colors.blueGrey,
        'screen': const BackupSettingsScreen(),
      },
      {
        'title': settings.translate('Support & Developer'),
        'subtitle': settings.translate('Contact support, report bugs & request features'),
        'icon': Icons.help_outline,
        'color': Colors.purple,
        'screen': const SupportSettingsScreen(),
      },
      {
        'title': settings.translate('About System'),
        'subtitle': settings.translate('App version, database schema v6 & licenses'),
        'icon': Icons.info_outline,
        'color': Colors.amber.shade800,
        'screen': const AboutSettingsScreen(),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings.translate('Settings'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.translate('Central application configuration & single source of truth'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('English'),
                    selected: !settings.isArabic,
                    onSelected: (val) {
                      if (val) settings.updateSettings({'is_arabic': false});
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('العربية'),
                    selected: settings.isArabic,
                    onSelected: (val) {
                      if (val) settings.updateSettings({'is_arabic': true});
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 2.2 / 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final section = sections[index];
                  final IconData icon = section['icon'];
                  final Color color = section['color'];

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => section['screen']),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: color.withOpacity(0.12),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    section['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    section['subtitle'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
