import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyClinicName = 'clinic_name';
  static const _keyClinicAddress = 'clinic_address';
  static const _keyClinicLicense = 'clinic_license';
  static const _keyClinicPhone = 'clinic_phone';
  static const _keyClinicEmail = 'clinic_email';
  static const _keyLogoPath = 'logo_path';
  static const _keyCurrency = 'currency';
  static const _keyIsArabic = 'is_arabic';

  static const _keyRxHeader = 'rx_header';
  static const _keyRxFooter = 'rx_footer';
  static const _keyRxSignature = 'rx_signature';
  static const _keyRxContactInfo = 'rx_contact_info';
  static const _keyRxNotes = 'rx_notes';

  static const _keyDefaultConsultationFee = 'default_consultation_fee';
  static const _keyPaymentMethods = 'payment_methods';

  static const _keyWhatsappNumber = 'whatsapp_number';
  static const _keyWhatsappReminder = 'whatsapp_reminder';
  static const _keyWhatsappConfirmation = 'whatsapp_confirmation';
  static const _keyWhatsappCancellation = 'whatsapp_cancellation';
  static const _keyWhatsappRecall = 'whatsapp_recall';

  Future<void> saveSettings(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data.containsKey('clinic_name')) await prefs.setString(_keyClinicName, data['clinic_name']);
    if (data.containsKey('clinic_address')) await prefs.setString(_keyClinicAddress, data['clinic_address']);
    if (data.containsKey('clinic_license')) await prefs.setString(_keyClinicLicense, data['clinic_license']);
    if (data.containsKey('clinic_phone')) await prefs.setString(_keyClinicPhone, data['clinic_phone']);
    if (data.containsKey('clinic_email')) await prefs.setString(_keyClinicEmail, data['clinic_email']);
    if (data.containsKey('logo_path')) await prefs.setString(_keyLogoPath, data['logo_path']);
    if (data.containsKey('currency')) await prefs.setString(_keyCurrency, data['currency']);
    if (data.containsKey('is_arabic')) await prefs.setBool(_keyIsArabic, data['is_arabic']);

    if (data.containsKey('rx_header')) await prefs.setString(_keyRxHeader, data['rx_header']);
    if (data.containsKey('rx_footer')) await prefs.setString(_keyRxFooter, data['rx_footer']);
    if (data.containsKey('rx_signature')) await prefs.setString(_keyRxSignature, data['rx_signature']);
    if (data.containsKey('rx_contact_info')) await prefs.setString(_keyRxContactInfo, data['rx_contact_info']);
    if (data.containsKey('rx_notes')) await prefs.setString(_keyRxNotes, data['rx_notes']);

    if (data.containsKey('default_consultation_fee')) await prefs.setDouble(_keyDefaultConsultationFee, data['default_consultation_fee']);
    if (data.containsKey('payment_methods')) await prefs.setStringList(_keyPaymentMethods, List<String>.from(data['payment_methods']));

    if (data.containsKey('whatsapp_number')) await prefs.setString(_keyWhatsappNumber, data['whatsapp_number']);
    if (data.containsKey('whatsapp_reminder')) await prefs.setString(_keyWhatsappReminder, data['whatsapp_reminder']);
    if (data.containsKey('whatsapp_confirmation')) await prefs.setString(_keyWhatsappConfirmation, data['whatsapp_confirmation']);
    if (data.containsKey('whatsapp_cancellation')) await prefs.setString(_keyWhatsappCancellation, data['whatsapp_cancellation']);
    if (data.containsKey('whatsapp_recall')) await prefs.setString(_keyWhatsappRecall, data['whatsapp_recall']);
  }

  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'clinic_name': prefs.getString(_keyClinicName) ?? 'Lumina Dental Clinic',
      'clinic_address': prefs.getString(_keyClinicAddress) ?? '123 Medical Complex, Suite 400',
      'clinic_license': prefs.getString(_keyClinicLicense) ?? 'License #DENT-987654',
      'clinic_phone': prefs.getString(_keyClinicPhone) ?? '+1 (555) 100-2000',
      'clinic_email': prefs.getString(_keyClinicEmail) ?? 'contact@lumina.clinic',
      'logo_path': prefs.getString(_keyLogoPath) ?? '',
      'currency': prefs.getString(_keyCurrency) ?? 'USD',
      'is_arabic': prefs.getBool(_keyIsArabic) ?? false,

      'rx_header': prefs.getString(_keyRxHeader) ?? 'LUMINA DENTAL CLINIC - PRESCRIPTION',
      'rx_footer': prefs.getString(_keyRxFooter) ?? 'Get well soon! Please present this slip at any pharmacy.',
      'rx_signature': prefs.getString(_keyRxSignature) ?? 'Dr. Sarah Johnson (D.D.S)',
      'rx_contact_info': prefs.getString(_keyRxContactInfo) ?? 'Tel: +1 (555) 100-2000 • Email: info@lumina.clinic',
      'rx_notes': prefs.getString(_keyRxNotes) ?? 'Take medications as instructed. Avoid cold drinks after procedure.',

      'default_consultation_fee': prefs.getDouble(_keyDefaultConsultationFee) ?? 25.0,
      'payment_methods': prefs.getStringList(_keyPaymentMethods) ?? ['Cash', 'Visa', 'MasterCard', 'Bank Transfer', 'Zain Cash', 'Qi Card'],

      'whatsapp_number': prefs.getString(_keyWhatsappNumber) ?? '+1 (555) 100-2000',
      'whatsapp_reminder': prefs.getString(_keyWhatsappReminder) ?? 'Dear {patient}, friendly reminder for your appointment at Lumina Clinic on {date} at {time}.',
      'whatsapp_confirmation': prefs.getString(_keyWhatsappConfirmation) ?? 'Dear {patient}, your appointment has been confirmed for {date} at {time}.',
      'whatsapp_cancellation': prefs.getString(_keyWhatsappCancellation) ?? 'Dear {patient}, your appointment on {date} has been cancelled.',
      'whatsapp_recall': prefs.getString(_keyWhatsappRecall) ?? 'Dear {patient}, it is time for your 6-month dental checkup at Lumina Clinic.',
    };
  }
}
