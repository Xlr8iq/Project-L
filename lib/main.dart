import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/dashboard/providers/clinic_provider.dart';
import 'features/dashboard/providers/settings_provider.dart';

void main() {
  // Initialize FFI for Windows/Desktop SQLite support.
  // We check !kIsWeb first because accessing Platform on Web throws an exception!
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClinicProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const DentalClinicApp(),
    ),
  );
}

class DentalClinicApp extends StatelessWidget {
  const DentalClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Dental Clinic',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            return Directionality(
              textDirection: settings.isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: child!,
            );
          },
          home: const DashboardScreen(),
        );
      },
    );
  }
}
