import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme.dart';
import '../../dashboard/providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _licenseController;
  String _logoPath = '';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.clinicName);
    _addressController = TextEditingController(text: provider.clinicAddress);
    _licenseController = TextEditingController(text: provider.clinicLicense);
    _logoPath = provider.logoPath;
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

  void _saveSettings() {
    Provider.of<SettingsProvider>(context, listen: false).saveSettings(
      name: _nameController.text,
      address: _addressController.text,
      license: _licenseController.text,
      logo: _logoPath,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Prescription template saved!'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                provider.translate('Edit Prescription Template'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  const Text('English', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(width: 8),
                  Switch(
                    value: provider.isArabic,
                    onChanged: (val) {
                      provider.toggleLanguage();
                    },
                    activeThumbColor: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  const Text('العربية', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            provider.translate('Configure the branding that will appear at the top of printed prescriptions.'),
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.translate('Clinic Logo'),
                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
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
                            : const Icon(Icons.business, size: 48, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 24),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.upload),
                        label: Text(provider.translate('Upload Logo')),
                        onPressed: _pickLogo,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Text(
                    provider.translate('Clinic Information'),
                    style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: provider.translate('Clinic Name')),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: provider.translate('Address & Contact')),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _licenseController,
                    decoration: InputDecoration(labelText: provider.translate('Doctor / License Information')),
                  ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _saveSettings,
                      child: Text(provider.translate('Save Template')),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
