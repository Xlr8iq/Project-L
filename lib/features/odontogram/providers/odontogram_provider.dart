import 'package:flutter/foundation.dart';
import '../../../core/models/tooth.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../../../core/database/database_helper.dart';
import '../../dashboard/providers/clinic_provider.dart';

class OdontogramProvider extends ChangeNotifier {
  int? patientId;
  
  // Initialize teeth 1 through 32
  final Map<int, Tooth> _teeth = {
    for (int i = 1; i <= 32; i++) i: Tooth(number: i)
  };

  Tooth getTooth(int number) => _teeth[number]!;
  
  // Teeth 1-16 (Upper) and 17-32 (Lower)
  List<Tooth> get upperJaw => List.generate(16, (i) => _teeth[i + 1]!);
  List<Tooth> get lowerJaw => List.generate(16, (i) => _teeth[i + 17]!);

  int? _selectedTooth;
  int? get selectedTooth => _selectedTooth;

  // ─── Draft Diagnosis Treatment Plan Items ───
  final Map<int, ProcedureType> _draftProcedures = {};
  Map<int, ProcedureType> get draftProcedures => Map.unmodifiable(_draftProcedures);

  // ─── Surface Selection ───
  final Set<Surface> _selectedSurfaces = {};
  Set<Surface> get selectedSurfaces => Set.unmodifiable(_selectedSurfaces);

  void toggleSurface(Surface surface) {
    if (_selectedSurfaces.contains(surface)) {
      _selectedSurfaces.remove(surface);
    } else {
      _selectedSurfaces.add(surface);
    }
    notifyListeners();
  }

  void clearSurfaces() {
    _selectedSurfaces.clear();
    notifyListeners();
  }

  // ─── Chart Loading ───
  Future<void> loadChart(int patientId) async {
    this.patientId = patientId;
    _draftProcedures.clear();
    if (!kIsWeb) {
      try {
        final savedTeeth = await DatabaseHelper.instance.getTeethForPatient(patientId);
        for (var tooth in savedTeeth) {
          _teeth[tooth.number] = tooth;
        }
      } catch (e) {
        debugPrint("Error loading chart: $e");
      }
    }
    notifyListeners();
  }

  // ─── Tooth Selection ───
  void selectTooth(int number) {
    if (_selectedTooth == number) {
      _selectedTooth = null;
    } else {
      _selectedTooth = number;
      _selectedSurfaces.clear();
    }
    notifyListeners();
  }

  // ─── Draft Diagnosis Procedure Assignment ───
  void assignDraftProcedure(ProcedureType type) {
    if (_selectedTooth != null) {
      if (type == ProcedureType.none) {
        _draftProcedures.remove(_selectedTooth);
        _teeth[_selectedTooth!] = _teeth[_selectedTooth!]!.copyWith(procedure: ProcedureType.none);
      } else {
        _draftProcedures[_selectedTooth!] = type;
        _teeth[_selectedTooth!] = _teeth[_selectedTooth!]!.copyWith(procedure: type);
      }
      notifyListeners();
    }
  }

  void removeDraftProcedure(int toothNumber) {
    _draftProcedures.remove(toothNumber);
    _teeth[toothNumber] = _teeth[toothNumber]!.copyWith(procedure: ProcedureType.none);
    notifyListeners();
  }

  // Legacy method for direct procedure application
  Future<void> applyProcedure(ProcedureType type) async {
    assignDraftProcedure(type);
  }

  // ─── Save Treatment Plan (Persists Draft Diagnosis) ───
  Future<void> saveTreatmentPlan(ClinicProvider clinicProvider) async {
    if (patientId == null) return;

    for (var entry in _draftProcedures.entries) {
      final toothNum = entry.key;
      final proc = entry.value;

      if (proc != ProcedureType.none) {
        // Save tooth overlay to teeth_chart table
        await DatabaseHelper.instance.saveToothProcedure(patientId!, _teeth[toothNum]!);

        int visits = 1;
        double fee = 50.0;

        final dummyItem = TreatmentPlanItem(patientId: 0, toothNumber: 1, procedureType: proc);
        final procName = dummyItem.procedureName;
        final matchedSetting = clinicProvider.procedures.where((p) =>
          p.name.toLowerCase().contains(procName.toLowerCase()) ||
          procName.toLowerCase().contains(p.name.toLowerCase())
        ).toList();

        if (matchedSetting.isNotEmpty) {
          fee = matchedSetting.first.defaultFee;
          visits = matchedSetting.first.defaultVisits;
        } else {
          if (proc == ProcedureType.endo) { visits = 3; fee = 180.0; }
          if (proc == ProcedureType.crown) { visits = 2; fee = 250.0; }
          if (proc == ProcedureType.implant) { visits = 3; fee = 400.0; }
          if (proc == ProcedureType.extraction) { visits = 1; fee = 70.0; }
        }

        final item = TreatmentPlanItem(
          patientId: patientId!,
          toothNumber: toothNum,
          procedureType: proc,
          status: TreatmentPlanStatus.planned,
          totalVisits: visits,
          estimatedFee: fee,
        );

        await clinicProvider.addTreatmentPlanItem(item);
      }
    }

    _draftProcedures.clear();
    notifyListeners();
  }
}
