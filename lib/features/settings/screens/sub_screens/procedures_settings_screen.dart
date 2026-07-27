import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../../core/models/procedure_setting.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../dashboard/providers/clinic_provider.dart';
import '../../../dashboard/providers/settings_provider.dart';

class ProceduresSettingsScreen extends StatelessWidget {
  const ProceduresSettingsScreen({Key? key}) : super(key: key);

  void _showProcedureDialog(BuildContext context, [ProcedureSetting? proc]) {
    final nameCtrl = TextEditingController(text: proc?.name ?? '');
    final feeCtrl = TextEditingController(text: proc != null ? ThousandsSeparatorInputFormatter.format(proc.defaultFee) : '50');
    final visitsCtrl = TextEditingController(text: proc != null ? proc.defaultVisits.toString() : '1');

    showDialog(
      context: context,
      builder: (dialogContext) {
        final settings = Provider.of<SettingsProvider>(dialogContext, listen: false);
        return AlertDialog(
          title: Text(proc == null ? 'Add Clinical Procedure' : 'Edit Procedure Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Procedure Name *', prefixIcon: Icon(Icons.medical_services)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: feeCtrl,
                  decoration: InputDecoration(
                    labelText: 'Default Fee *',
                    suffixText: settings.currencySuffix,
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: visitsCtrl,
                  decoration: const InputDecoration(labelText: 'Default Planned Visits', prefixIcon: Icon(Icons.repeat)),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final fee = ThousandsSeparatorInputFormatter.parse(feeCtrl.text.trim());
                final visits = int.tryParse(visitsCtrl.text.trim()) ?? 1;

                final clinic = Provider.of<ClinicProvider>(context, listen: false);

                if (proc == null) {
                  await clinic.addProcedureSetting(
                    ProcedureSetting(
                      name: nameCtrl.text.trim(),
                      defaultFee: fee,
                      currency: settings.currency,
                      defaultVisits: visits,
                    ),
                  );
                } else {
                  await clinic.updateProcedureSetting(
                    proc.copyWith(
                      name: nameCtrl.text.trim(),
                      defaultFee: fee,
                      currency: settings.currency,
                      defaultVisits: visits,
                    ),
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('Procedures & Fees Settings')),
      ),
      body: Consumer<ClinicProvider>(
        builder: (context, clinic, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
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
                          settings.translate('Clinical Procedures & Default Pricing'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settings.translate('Configure fees and default visits that automatically populate treatment plans.'),
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add),
                      label: Text(settings.translate('Add Procedure')),
                      onPressed: () => _showProcedureDialog(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: clinic.procedures.isEmpty
                      ? Center(child: Text(settings.translate('No procedures configured.')))
                      : ListView.separated(
                          itemCount: clinic.procedures.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final p = clinic.procedures[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                  child: const Icon(Icons.medical_services, color: AppTheme.primaryBlue),
                                ),
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Text('${p.defaultVisits} ${settings.translate("Default Visits")} • ${settings.translate(p.isActive ? "Active" : "Inactive")}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      settings.formatCurrency(p.defaultFee),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                                      onPressed: () => _showProcedureDialog(context, p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => clinic.deleteProcedureSetting(p.id!),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
