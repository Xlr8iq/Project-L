import 'package:flutter/foundation.dart';
import '../../../core/models/tooth.dart';
import '../../../core/database/database_helper.dart';

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
    if (!kIsWeb) {
      try {
        final savedTeeth = await DatabaseHelper.instance.getTeethForPatient(patientId);
        for (var tooth in savedTeeth) {
          _teeth[tooth.number] = tooth;
        }
      } catch (e) {
        print("Error loading chart: $e");
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
      _selectedSurfaces.clear(); // Clear surfaces when switching teeth
    }
    notifyListeners();
  }

  // ─── Procedure ───
  Future<void> applyProcedure(ProcedureType type) async {
    if (_selectedTooth != null) {
      _teeth[_selectedTooth!] = _teeth[_selectedTooth!]!.copyWith(procedure: type);
      notifyListeners();
      
      if (patientId != null && !kIsWeb) {
        try {
          await DatabaseHelper.instance.saveToothProcedure(patientId!, _teeth[_selectedTooth!]!);
        } catch (e) {
          print("Error saving procedure: $e");
        }
      }
    }
  }
}
