import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/localization/translations.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service = SettingsService();

  // Clinic Info
  String clinicName = 'Lumina Dental Clinic';
  String clinicAddress = '123 Medical Complex, Suite 400';
  String clinicLicense = 'License #DENT-987654';
  String clinicPhone = '+1 (555) 100-2000';
  String clinicEmail = 'contact@lumina.clinic';
  String logoPath = '';
  String currency = 'USD'; // 'USD' or 'IQD'
  bool isArabic = false;
  bool isLoading = true;

  // Prescription Customization
  String rxHeader = 'LUMINA DENTAL CLINIC - PRESCRIPTION';
  String rxFooter = 'Get well soon! Please present this slip at any pharmacy.';
  String rxSignature = 'Dr. Sarah Johnson (D.D.S)';
  String rxContactInfo = 'Tel: +1 (555) 100-2000 • Email: info@lumina.clinic';
  String rxNotes = 'Take medications as instructed.';

  // Financial Settings
  double defaultConsultationFee = 25.0;
  List<String> enabledPaymentMethods = ['Cash', 'Visa', 'MasterCard', 'Bank Transfer', 'Zain Cash', 'Qi Card'];

  // WhatsApp Settings
  String whatsappNumber = '+1 (555) 100-2000';
  String whatsappReminderTemplate = 'Dear {patient}, friendly reminder for your appointment at Lumina Clinic on {date} at {time}.';
  String whatsappConfirmationTemplate = 'Dear {patient}, your appointment has been confirmed for {date} at {time}.';
  String whatsappCancellationTemplate = 'Dear {patient}, your appointment on {date} has been cancelled.';
  String whatsappRecallTemplate = 'Dear {patient}, it is time for your 6-month dental checkup at Lumina Clinic.';

  SettingsProvider() {
    loadSettings();
  }

  String get currencySymbol {
    if (currency == 'IQD') return isArabic ? 'ع.د' : 'IQD';
    return 'USD (\$)';
  }

  String get currencySuffix {
    if (currency == 'IQD') return isArabic ? 'د.ع' : 'IQD';
    return '\$';
  }

  String formatCurrency(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    final formattedNum = formatter.format(amount.round());
    if (!showSymbol) return formattedNum;
    if (currency == 'IQD') {
      return isArabic ? '$formattedNum د.ع' : '$formattedNum IQD';
    }
    return '\$$formattedNum';
  }

  String formatDate(DateTime date) {
    if (isArabic) {
      final monthsAr = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${monthsAr[date.month - 1]} ${date.year}';
    } else {
      return DateFormat('MMMM dd, yyyy').format(date);
    }
  }

  String formatDateShort(DateTime date) {
    if (isArabic) {
      final monthsAr = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return '${date.day} ${monthsAr[date.month - 1]}';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  String formatMonthShort(DateTime date) {
    if (isArabic) {
      final monthsAr = [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
      ];
      return monthsAr[date.month - 1];
    } else {
      return DateFormat('MMM').format(date).toUpperCase();
    }
  }

  String formatWeekdayShort(DateTime date) {
    if (isArabic) {
      final daysAr = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
      return daysAr[date.weekday - 1];
    } else {
      return DateFormat('E').format(date);
    }
  }

  String formatTime(DateTime date) {
    if (isArabic) {
      final hour = DateFormat('hh:mm').format(date);
      final period = date.hour >= 12 ? 'م' : 'ص';
      return '$hour $period';
    } else {
      return DateFormat('hh:mm a').format(date);
    }
  }

  String translate(String key) {
    if (!isArabic) return key;
    return Translations.ar[key] ?? key;
  }

  void toggleLanguage() {
    isArabic = !isArabic;
    updateSettings({'is_arabic': isArabic});
  }

  void setCurrency(String newCurrency) {
    currency = newCurrency;
    updateSettings({'currency': newCurrency});
  }

  Future<void> loadSettings() async {
    isLoading = true;
    notifyListeners();

    final data = await _service.loadSettings();
    clinicName = data['clinic_name'];
    clinicAddress = data['clinic_address'];
    clinicLicense = data['clinic_license'];
    clinicPhone = data['clinic_phone'];
    clinicEmail = data['clinic_email'];
    logoPath = data['logo_path'];
    currency = data['currency'];
    isArabic = data['is_arabic'];

    rxHeader = data['rx_header'];
    rxFooter = data['rx_footer'];
    rxSignature = data['rx_signature'];
    rxContactInfo = data['rx_contact_info'];
    rxNotes = data['rx_notes'];

    defaultConsultationFee = (data['default_consultation_fee'] as num).toDouble();
    enabledPaymentMethods = List<String>.from(data['payment_methods']);

    whatsappNumber = data['whatsapp_number'];
    whatsappReminderTemplate = data['whatsapp_reminder'];
    whatsappConfirmationTemplate = data['whatsapp_confirmation'];
    whatsappCancellationTemplate = data['whatsapp_cancellation'];
    whatsappRecallTemplate = data['whatsapp_recall'];

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    if (data.containsKey('clinic_name')) clinicName = data['clinic_name'];
    if (data.containsKey('clinic_address')) clinicAddress = data['clinic_address'];
    if (data.containsKey('clinic_license')) clinicLicense = data['clinic_license'];
    if (data.containsKey('clinic_phone')) clinicPhone = data['clinic_phone'];
    if (data.containsKey('clinic_email')) clinicEmail = data['clinic_email'];
    if (data.containsKey('logo_path')) logoPath = data['logo_path'];
    if (data.containsKey('currency')) currency = data['currency'];
    if (data.containsKey('is_arabic')) isArabic = data['is_arabic'];

    if (data.containsKey('rx_header')) rxHeader = data['rx_header'];
    if (data.containsKey('rx_footer')) rxFooter = data['rx_footer'];
    if (data.containsKey('rx_signature')) rxSignature = data['rx_signature'];
    if (data.containsKey('rx_contact_info')) rxContactInfo = data['rx_contact_info'];
    if (data.containsKey('rx_notes')) rxNotes = data['rx_notes'];

    if (data.containsKey('default_consultation_fee')) defaultConsultationFee = (data['default_consultation_fee'] as num).toDouble();
    if (data.containsKey('payment_methods')) enabledPaymentMethods = List<String>.from(data['payment_methods']);

    if (data.containsKey('whatsapp_number')) whatsappNumber = data['whatsapp_number'];
    if (data.containsKey('whatsapp_reminder')) whatsappReminderTemplate = data['whatsapp_reminder'];
    if (data.containsKey('whatsapp_confirmation')) whatsappConfirmationTemplate = data['whatsapp_confirmation'];
    if (data.containsKey('whatsapp_cancellation')) whatsappCancellationTemplate = data['whatsapp_cancellation'];
    if (data.containsKey('whatsapp_recall')) whatsappRecallTemplate = data['whatsapp_recall'];

    await _service.saveSettings(data);
    notifyListeners();
  }
}
