import 'package:flutter/foundation.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../../../core/models/doctor.dart';
import '../../../core/models/procedure_setting.dart';
import '../../../core/models/secretary.dart';

class ClinicProvider extends ChangeNotifier {
  List<Patient> patients = [];
  List<Appointment> appointments = [];
  List<Doctor> doctors = [];
  List<ProcedureSetting> procedures = [];
  List<Secretary> secretaries = [];

  Map<int, List<TreatmentPlanItem>> _treatmentPlans = {};
  bool isLoading = false;
  int _webIdCounter = 1;

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    if (!kIsWeb) {
      try {
        doctors = await DatabaseHelper.instance.readAllDoctors();
        procedures = await DatabaseHelper.instance.readAllProcedureSettings();
        secretaries = await DatabaseHelper.instance.readAllSecretaries();
        patients = await DatabaseHelper.instance.readAllPatients();
        appointments = await DatabaseHelper.instance.readAllAppointments();
      } catch (e) {
        debugPrint("DB Load Error: $e");
      }
    } else {
      if (doctors.isEmpty) {
        doctors = [
          Doctor(id: 1, name: 'Dr. Sarah Johnson', specialty: 'Endodontics & Restorative'),
          Doctor(id: 2, name: 'Dr. Michael Chen', specialty: 'Orthodontics & General'),
          Doctor(id: 3, name: 'Dr. Emily Taylor', specialty: 'Prosthodontics & Cosmetic'),
          Doctor(id: 4, name: 'Dr. Alex Smith', specialty: 'Oral Surgery & Implants'),
        ];
      }
      if (procedures.isEmpty) {
        procedures = [
          ProcedureSetting(id: 1, name: 'Composite Restoration', defaultFee: 50.0, defaultVisits: 1),
          ProcedureSetting(id: 2, name: 'Root Canal (RCT)', defaultFee: 180.0, defaultVisits: 3),
          ProcedureSetting(id: 3, name: 'Extraction', defaultFee: 70.0, defaultVisits: 1),
          ProcedureSetting(id: 4, name: 'Crown', defaultFee: 250.0, defaultVisits: 2),
        ];
      }
      if (secretaries.isEmpty) {
        secretaries = [
          Secretary(id: 1, name: 'Hadeel Kareem', phone: '+1 (555) 987-6543', username: 'secretary1', password: '123'),
        ];
      }
    }

    isLoading = false;
    notifyListeners();
  }

  // ─── Doctor Management ───

  Future<Doctor> addDoctor(Doctor doctor) async {
    Doctor newDoc;
    if (kIsWeb) {
      newDoc = doctor.copyWith(id: _webIdCounter++);
    } else {
      newDoc = await DatabaseHelper.instance.createDoctor(doctor);
    }
    doctors.add(newDoc);
    notifyListeners();
    return newDoc;
  }

  Future<void> updateDoctor(Doctor doctor) async {
    final index = doctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      doctors[index] = doctor;
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateDoctor(doctor);
      }
      notifyListeners();
    }
  }

  Future<void> deleteDoctor(int doctorId) async {
    doctors.removeWhere((d) => d.id == doctorId);
    if (!kIsWeb) {
      await DatabaseHelper.instance.deleteDoctor(doctorId);
    }
    notifyListeners();
  }

  // ─── Secretary Management ───

  Future<Secretary> addSecretary(Secretary secretary) async {
    Secretary newSec;
    if (kIsWeb) {
      newSec = secretary.copyWith(id: _webIdCounter++);
    } else {
      newSec = await DatabaseHelper.instance.createSecretary(secretary);
    }
    secretaries.add(newSec);
    notifyListeners();
    return newSec;
  }

  Future<void> updateSecretary(Secretary secretary) async {
    final index = secretaries.indexWhere((s) => s.id == secretary.id);
    if (index != -1) {
      secretaries[index] = secretary;
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateSecretary(secretary);
      }
      notifyListeners();
    }
  }

  Future<void> deleteSecretary(int secretaryId) async {
    secretaries.removeWhere((s) => s.id == secretaryId);
    if (!kIsWeb) {
      await DatabaseHelper.instance.deleteSecretary(secretaryId);
    }
    notifyListeners();
  }

  // ─── Procedure Settings Management ───

  Future<ProcedureSetting> addProcedureSetting(ProcedureSetting proc) async {
    ProcedureSetting newProc;
    if (kIsWeb) {
      newProc = proc.copyWith(id: _webIdCounter++);
    } else {
      newProc = await DatabaseHelper.instance.createProcedureSetting(proc);
    }
    procedures.add(newProc);
    notifyListeners();
    return newProc;
  }

  Future<void> updateProcedureSetting(ProcedureSetting proc) async {
    final index = procedures.indexWhere((p) => p.id == proc.id);
    if (index != -1) {
      procedures[index] = proc;
      if (!kIsWeb) {
        await DatabaseHelper.instance.updateProcedureSetting(proc);
      }
      notifyListeners();
    }
  }

  Future<void> deleteProcedureSetting(int procId) async {
    procedures.removeWhere((p) => p.id == procId);
    if (!kIsWeb) {
      await DatabaseHelper.instance.deleteProcedureSetting(procId);
    }
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

    if (newItem.nextVisitDate != null) {
      await syncNextVisitAppointment(
        patientId: newItem.patientId,
        visitDate: newItem.nextVisitDate!,
        procedureName: newItem.procedureName,
        palmerCode: newItem.palmerCode,
        visitNumber: newItem.currentVisit,
        totalVisits: newItem.totalVisits,
        doctorName: newItem.doctorName,
      );
    }

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

        if (item.nextVisitDate != null && item.status != TreatmentPlanStatus.completed) {
          await syncNextVisitAppointment(
            patientId: item.patientId,
            visitDate: item.nextVisitDate!,
            procedureName: item.procedureName,
            palmerCode: item.palmerCode,
            visitNumber: item.currentVisit,
            totalVisits: item.totalVisits,
            doctorName: item.doctorName,
          );
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

  // ─── Automatic Appointment Synchronization ───

  Future<Appointment?> syncNextVisitAppointment({
    required int patientId,
    required DateTime visitDate,
    required String procedureName,
    required String palmerCode,
    required int visitNumber,
    required int totalVisits,
    required String doctorName,
  }) async {
    final noteText = '$procedureName (Visit $visitNumber/$totalVisits) - Tooth $palmerCode • Doctor: $doctorName';

    final existingIndex = appointments.indexWhere((a) =>
      a.patientId == patientId &&
      a.dateTime.year == visitDate.year &&
      a.dateTime.month == visitDate.month &&
      a.dateTime.day == visitDate.day &&
      a.notes.contains(procedureName)
    );

    if (existingIndex != -1) {
      final updatedAppt = appointments[existingIndex].copyWith(
        dateTime: visitDate,
        notes: noteText,
      );
      await updateAppointment(updatedAppt);
      return updatedAppt;
    } else {
      final newAppt = await addAppointment(patientId, visitDate, noteText);
      return newAppt;
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

  // ─── Synchronized Live Dashboard Metrics Getters ───

  int get todayPatientsCount {
    final now = DateTime.now();
    final todayPatientIds = appointments.where((a) =>
      a.dateTime.year == now.year &&
      a.dateTime.month == now.month &&
      a.dateTime.day == now.day
    ).map((a) => a.patientId).toSet();
    return todayPatientIds.length;
  }

  int get upcomingAppointmentsCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return appointments.where((a) => a.dateTime.isAfter(todayStart) || a.dateTime.isAtSameMomentAs(todayStart)).length;
  }

  int get completedTreatmentsCount {
    int total = 0;
    for (var list in _treatmentPlans.values) {
      total += list.where((i) => i.status == TreatmentPlanStatus.completed).length;
    }
    return total;
  }

  int get pendingTreatmentsCount {
    int total = 0;
    for (var list in _treatmentPlans.values) {
      total += list.where((i) => i.status == TreatmentPlanStatus.planned || i.status == TreatmentPlanStatus.inProgress || i.status == TreatmentPlanStatus.waitingForLab).length;
    }
    return total;
  }

  double get totalOutstandingBalance {
    double total = 0.0;
    for (var list in _treatmentPlans.values) {
      for (var item in list) {
        total += item.remainingBalance;
      }
    }
    return total;
  }
}
