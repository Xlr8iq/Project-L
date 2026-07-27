import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/treatment_plan_item.dart';

class ClinicProvider extends ChangeNotifier {
  List<Patient> patients = [];
  List<Appointment> appointments = [];
  Map<int, List<TreatmentPlanItem>> _treatmentPlans = {};
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

  // ─── Treatment Plan Management ───

  List<TreatmentPlanItem> getTreatmentPlan(int patientId) {
    return _treatmentPlans[patientId] ?? [];
  }

  Future<void> loadTreatmentPlan(int patientId) async {
    if (!kIsWeb) {
      try {
        final items = await DatabaseHelper.instance.getTreatmentPlanForPatient(patientId);
        _treatmentPlans[patientId] = items;
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading treatment plan: $e");
      }
    }
  }

  Future<TreatmentPlanItem> addTreatmentPlanItem(TreatmentPlanItem item) async {
    TreatmentPlanItem newItem;
    if (kIsWeb) {
      newItem = item.copyWith(id: _webIdCounter++);
    } else {
      newItem = await DatabaseHelper.instance.createTreatmentPlanItem(item);
    }

    final list = _treatmentPlans[item.patientId] ?? [];
    list.add(newItem);
    _treatmentPlans[item.patientId] = list;
    notifyListeners();
    return newItem;
  }

  Future<void> updateTreatmentPlanItem(TreatmentPlanItem item) async {
    final list = _treatmentPlans[item.patientId];
    if (list != null) {
      final idx = list.indexWhere((i) => i.id == item.id);
      if (idx != -1) {
        list[idx] = item;
        if (!kIsWeb) {
          await DatabaseHelper.instance.updateTreatmentPlanItem(item);
        }
        notifyListeners();
      }
    }
  }

  Future<void> deleteTreatmentPlanItem(int patientId, int itemId) async {
    final list = _treatmentPlans[patientId];
    if (list != null) {
      list.removeWhere((i) => i.id == itemId);
      if (!kIsWeb) {
        await DatabaseHelper.instance.deleteTreatmentPlanItem(itemId);
      }
      notifyListeners();
    }
  }

  Future<void> saveDraftTreatmentPlan(int patientId, List<TreatmentPlanItem> items) async {
    for (var item in items) {
      await addTreatmentPlanItem(item.copyWith(patientId: patientId));
    }
  }

  // ─── Patient CRUD ───

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
    }
    patients.add(newPatient);
    notifyListeners();
    return newPatient;
  }

  Future<void> updatePatient(Patient patient) async {
    final index = patients.indexWhere((p) => p.id == patient.id);
    if (index != -1) {
      patients[index] = patient;
      if (!kIsWeb) {
        await DatabaseHelper.instance.updatePatient(patient);
      }
      notifyListeners();
    }
  }

  // ─── Appointment CRUD ───

  Future<Appointment> addAppointment(int patientId, DateTime dateTime, String notes) async {
    Appointment newAppt;
    if (kIsWeb) {
      newAppt = Appointment(id: _webIdCounter++, patientId: patientId, dateTime: dateTime, notes: notes);
    } else {
      final a = Appointment(patientId: patientId, dateTime: dateTime, notes: notes);
      newAppt = await DatabaseHelper.instance.createAppointment(a);
    }
    appointments.add(newAppt);
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
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }
}
