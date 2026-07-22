import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyClinicName = 'clinic_name';
  static const _keyClinicAddress = 'clinic_address';
  static const _keyClinicLicense = 'clinic_license';
  static const _keyLogoPath = 'logo_path';
  static const _keyIsArabic = 'is_arabic';

  Future<void> saveSettings({
    required String clinicName,
    required String clinicAddress,
    required String clinicLicense,
    required String logoPath,
    required bool isArabic,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyClinicName, clinicName);
    await prefs.setString(_keyClinicAddress, clinicAddress);
    await prefs.setString(_keyClinicLicense, clinicLicense);
    await prefs.setString(_keyLogoPath, logoPath);
    await prefs.setBool(_keyIsArabic, isArabic);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      _keyClinicName: prefs.getString(_keyClinicName) ?? 'My Dental Clinic',
      _keyClinicAddress: prefs.getString(_keyClinicAddress) ?? '123 Main St, City, Country',
      _keyClinicLicense: prefs.getString(_keyClinicLicense) ?? 'License #123456',
      _keyLogoPath: prefs.getString(_keyLogoPath) ?? '',
      _keyIsArabic: prefs.getBool(_keyIsArabic) ?? false,
    };
  }
}
