import 'package:flutter/foundation.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/localization/translations.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  String clinicName = 'My Dental Clinic';
  String clinicAddress = '123 Main St, City, Country';
  String clinicLicense = 'License #123456';
  String logoPath = '';
  bool isArabic = false;
  bool isLoading = true;

  SettingsProvider() {
    loadSettings();
  }

  String translate(String key) {
    if (!isArabic) return key;
    return Translations.ar[key] ?? key;
  }

  void toggleLanguage() {
    isArabic = !isArabic;
    saveSettings(name: clinicName, address: clinicAddress, license: clinicLicense, logo: logoPath, arabic: isArabic);
  }

  Future<void> loadSettings() async {
    isLoading = true;
    notifyListeners();

    final settings = await _service.loadSettings();
    clinicName = settings['clinic_name']!;
    clinicAddress = settings['clinic_address']!;
    clinicLicense = settings['clinic_license']!;
    logoPath = settings['logo_path']!;
    isArabic = settings['is_arabic'] ?? false;

    isLoading = false;
    notifyListeners();
  }

  Future<void> saveSettings({
    required String name,
    required String address,
    required String license,
    required String logo,
    bool? arabic,
  }) async {
    clinicName = name;
    clinicAddress = address;
    clinicLicense = license;
    logoPath = logo;
    if (arabic != null) isArabic = arabic;

    await _service.saveSettings(
      clinicName: name,
      clinicAddress: address,
      clinicLicense: license,
      logoPath: logo,
      isArabic: isArabic,
    );

    notifyListeners();
  }
}
