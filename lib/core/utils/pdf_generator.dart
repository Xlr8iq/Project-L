import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../../features/dashboard/providers/settings_provider.dart';

class PdfGenerator {
  static Future<void> printPrescription({
    required Patient patient,
    required Appointment appointment,
    required SettingsProvider settings,
  }) async {
    final doc = pw.Document();

    // Try to load the logo if a path is provided and exists
    pw.ImageProvider? logoImage;
    if (settings.logoPath.isNotEmpty && File(settings.logoPath).existsSync()) {
      try {
        final imageFile = File(settings.logoPath);
        final imageBytes = await imageFile.readAsBytes();
        logoImage = pw.MemoryImage(imageBytes);
      } catch (e) {
        // Logo failed to load
      }
    }

    // Load custom Arabic font
    final fontData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final fontBoldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final ttfBold = pw.Font.ttf(fontBoldData);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: settings.isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // HEADER: Clinic Info & Logo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(settings.clinicName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                          pw.SizedBox(height: 8),
                          pw.Text(settings.clinicAddress, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                          pw.SizedBox(height: 4),
                          pw.Text(settings.clinicLicense, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                    if (logoImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey400, thickness: 2),
                pw.SizedBox(height: 20),

                // PATIENT INFO
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${settings.translate("Full Name")}: ${patient.name}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('${settings.translate("Age")}/${settings.translate("Gender")}: ${patient.age} / ${settings.translate(patient.gender)}', style: const pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text('${settings.translate("Patient ID")}: #${patient.id.toString().padLeft(4, "0")}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('${settings.translate("Date & Time")}: ${DateFormat("MMMM d, yyyy").format(appointment.dateTime)}', style: const pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 4),
                        pw.Text(DateFormat('hh:mm a').format(appointment.dateTime), style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 40),

                // PRESCRIPTION BODY (Rx)
                pw.Text('Rx', style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic)),
                pw.SizedBox(height: 20),
                
                if (appointment.medications.isNotEmpty)
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: settings.isArabic ? 0 : 20, right: settings.isArabic ? 20 : 0),
                    child: pw.Text(
                      appointment.medications,
                      style: const pw.TextStyle(fontSize: 16, lineSpacing: 5),
                    ),
                  )
                else
                  pw.Padding(
                    padding: pw.EdgeInsets.only(left: settings.isArabic ? 0 : 20, right: settings.isArabic ? 20 : 0),
                    child: pw.Text(
                      settings.translate('No medications prescribed for this visit.'),
                      style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic),
                    ),
                  ),

                pw.Spacer(),

                // FOOTER: Signature
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(width: 200, height: 1, color: PdfColors.black),
                        pw.SizedBox(height: 8),
                        pw.Text(settings.translate('Doctor Signature'), style: const pw.TextStyle(fontSize: 12)),
                      ]
                    )
                  ]
                ),
                pw.SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );

    // Show Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Prescription_${patient.name.replaceAll(" ", "_")}_${DateFormat("yyyyMMdd").format(appointment.dateTime)}.pdf',
    );
  }
}
