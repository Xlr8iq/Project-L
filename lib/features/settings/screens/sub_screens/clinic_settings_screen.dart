import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme.dart';
import '../../../dashboard/providers/settings_provider.dart';

class ClinicSettingsScreen extends StatefulWidget {
  const ClinicSettingsScreen({Key? key}) : super(key: key);

  @override
  State<ClinicSettingsScreen> createState() => _ClinicSettingsScreenState();
}

class _ClinicSettingsScreenState extends State<ClinicSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  String _logoPath = '';
  late String _currency;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.clinicName);
    _addressController = TextEditingController(text: provider.clinicAddress);
    _phoneController = TextEditingController(text: provider.clinicPhone);
    _emailController = TextEditingController(text: provider.clinicEmail);
    _logoPath = provider.logoPath;
    _currency = provider.currency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoPath = pickedFile.path;
      });
    }
  }

  void _saveClinicSettings() {
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    provider.updateSettings({
      'clinic_name': _nameController.text.trim(),
      'clinic_address': _addressController.text.trim(),
      'clinic_phone': _phoneController.text.trim(),
      'clinic_email': _emailController.text.trim(),
      'logo_path': _logoPath,
      'currency': _currency,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.translate('Clinic settings updated successfully!')),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.translate('Clinic Information')),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_hospital, color: AppTheme.primaryBlue, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              provider.translate('Clinic Details & Branding'),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(provider.translate('Language:'), style: const TextStyle(fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('English'),
                              selected: !provider.isArabic,
                              onSelected: (val) {
                                if (val) provider.updateSettings({'is_arabic': false});
                              },
                            ),
                            const SizedBox(width: 4),
                            ChoiceChip(
                              label: const Text('العربية'),
                              selected: provider.isArabic,
                              onSelected: (val) {
                                if (val) provider.updateSettings({'is_arabic': true});
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.borderLight),
                    const SizedBox(height: 20),

                    // Logo Uploader
                    Text(
                      provider.translate('Clinic Logo'),
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: _logoPath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(_logoPath), fit: BoxFit.cover),
                                )
                              : const Icon(Icons.business, size: 42, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(width: 20),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.upload),
                          label: Text(provider.translate('Upload Logo')),
                          onPressed: _pickLogo,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Clinic Text Fields
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Clinic Name'),
                        prefixIcon: const Icon(Icons.local_hospital_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: provider.translate('Address'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: provider.translate('Phone Number'),
                              prefixIcon: const Icon(Icons.phone_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: provider.translate('Email (Optional)'),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Currency Selector
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: provider.translate('Clinic Currency'),
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                      ),
                      value: _currency,
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD ($) - United States Dollar')),
                        DropdownMenuItem(value: 'IQD', child: Text('IQD (ع.د) - Iraqi Dinar')),
                      ],
                      onChanged: (val) {
                        setState(() => _currency = val!);
                      },
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
                        onPressed: _saveClinicSettings,
                        child: Text(provider.translate('Save Clinic Settings')),
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
