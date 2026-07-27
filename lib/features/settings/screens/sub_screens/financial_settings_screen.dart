import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class FinancialSettingsScreen extends StatefulWidget {
  const FinancialSettingsScreen({Key? key}) : super(key: key);

  @override
  State<FinancialSettingsScreen> createState() => _FinancialSettingsScreenState();
}

class _FinancialSettingsScreenState extends State<FinancialSettingsScreen> {
  late TextEditingController _consultationFeeController;
  late List<String> _enabledMethods;
  final List<String> _allAvailableMethods = [
    'Cash',
    'Visa',
    'MasterCard',
    'Bank Transfer',
    'Zain Cash',
    'Qi Card',
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _consultationFeeController = TextEditingController(text: provider.defaultConsultationFee.toStringAsFixed(0));
    _enabledMethods = List<String>.from(provider.enabledPaymentMethods);
  }

  @override
  void dispose() {
    _consultationFeeController.dispose();
    super.dispose();
  }

  void _saveFinancialSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    final fee = double.tryParse(_consultationFeeController.text.trim()) ?? 25.0;

    provider.updateSettings({
      'default_consultation_fee': fee,
      'payment_methods': _enabledMethods,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.translate('Financial settings saved!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.translate('Financial Settings')),
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
                        const Icon(Icons.account_balance_wallet_outlined, color: AppTheme.primaryBlue, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          provider.translate('Financial & Billing Settings'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    TextField(
                      controller: _consultationFeeController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Default Consultation Fee'),
                        prefixIcon: const Icon(Icons.attach_money),
                        suffixText: provider.currencySymbol,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      provider.translate('Available Payment Methods'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    const SizedBox(height: 12),

                    Column(
                      children: _allAvailableMethods.map((method) {
                        final isEnabled = _enabledMethods.contains(method);
                        return CheckboxListTile(
                          title: Text(method, style: const TextStyle(fontWeight: FontWeight.w600)),
                          value: isEnabled,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                if (!_enabledMethods.contains(method)) _enabledMethods.add(method);
                              } else {
                                _enabledMethods.remove(method);
                              }
                            });
                          },
                        );
                      }).toList(),
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
                        onPressed: _saveFinancialSettings,
                        child: Text(provider.translate('Save Financial Settings')),
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
