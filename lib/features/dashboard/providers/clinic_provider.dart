import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';

class ClinicProvider extends ChangeNotifier {
  List<Patient> patients = [];
  List<Appointment> appointments = [];
  bool isLoading = false;
  int _webIdCounter = 1;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    if (!kIsWeb) {
      try {
        patients = await DatabaseHelper.instance.readAllPatients();
        appointments = await DatabaseHelper.instance.readAllAppointments();
      } catch (e) {
        debugPrint("DB Load Error: $e");
      }
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Patient> addPatient(
    String name,
    int age,
    String gender, {
    String phone = '',
    String address = '',
    String emergencyContact = '',
    String emergencyPhone = '',
    DateTime? dateOfBirth,
  }) async {
    Patient newPatient;
    final patientObj = Patient(
      name: name,
      age: age,
      gender: gender,
      createdAt: DateTime.now(),
      phone: phone,
      address: address,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
      dateOfBirth: dateOfBirth,
    );

    if (kIsWeb) {
      newPatient = Patient(
        id: _webIdCounter++,
        name: name,
        age: age,
        gender: gender,
        createdAt: DateTime.now(),
        phone: phone,
        address: address,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        dateOfBirth: dateOfBirth,
      );
    } else {
      newPatient = await DatabaseHelper.instance.createPatient(patientObj);
      // Ensure in-memory object keeps extra fields
      newPatient = Patient(
        id: newPatient.id,
        name: name,
        age: age,
        gender: gender,
        createdAt: newPatient.createdAt,
        phone: phone,
        address: address,
        emergencyContact: emergencyContact,
        emergencyPhone: emergencyPhone,
        dateOfBirth: dateOfBirth,
      );
    }
    patients.add(newPatient);
    notifyListeners();
    return newPatient;
  }

  Future<Appointment> addAppointment(int patientId, DateTime dateTime, String notes) async {
    Appointment newAppt;
    if (kIsWeb) {
      newAppt = Appointment(id: _webIdCounter++, patientId: patientId, dateTime: dateTime, notes: notes);
    } else {
      final a = Appointment(patientId: patientId, dateTime: dateTime, notes: notes);
      newAppt = await DatabaseHelper.instance.createAppointment(a);
    }
    appointments.add(newAppt);
    
    // Sort appointments chronologically
    appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    notifyListeners();
    return newAppt;
  }

  Patient? getPatientById(int id) {
    try {
      return patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateAppointment(Appointment updatedAppt) async {
    final index = appointments.indexWhere((a) => a.id == updatedAppt.id);
    if (index != -1) {
      appointments[index] = updatedAppt;
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateAppointment(updatedAppt);
      }
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    }
  }

  List<Appointment> getAppointmentsForPatient(int patientId) {
    return appointments.where((a) => a.patientId == patientId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime)); // newest first
  }
}
