enum ProcedureType { none, restoration, extraction, endo, implant, crown, veneer, bridge }

enum Surface { mesial, distal, buccal, lingual, occlusal }

enum ToothShape { centralIncisor, lateralIncisor, canine, firstPremolar, secondPremolar, firstMolar, secondMolar, thirdMolar }

class Tooth {
  final int number; // Universal numbering 1-32
  final ProcedureType procedure;

  Tooth({required this.number, this.procedure = ProcedureType.none});

  // ─── Palmer Notation ───

  /// Palmer quadrant: 1=UR, 2=UL, 3=LL, 4=LR
  int get palmerQuadrant {
    if (number >= 1 && number <= 8) return 1;
    if (number >= 9 && number <= 16) return 2;
    if (number >= 17 && number <= 24) return 3;
    if (number >= 25 && number <= 32) return 4;
    return 0;
  }

  /// Palmer tooth number (1–8 within quadrant)
  int get palmerNumber {
    switch (palmerQuadrant) {
      case 1: return 9 - number;       // Universal 1→8, 2→7, ... 8→1
      case 2: return number - 8;       // Universal 9→1, 10→2, ... 16→8
      case 3: return 25 - number;      // Universal 17→8, 18→7, ... 24→1
      case 4: return number - 24;      // Universal 25→1, 26→2, ... 32→8
      default: return 0;
    }
  }

  /// Legacy display number (same as palmerNumber)
  String get displayNumber => '$palmerNumber';

  bool get isUpper => palmerQuadrant == 1 || palmerQuadrant == 2;
  bool get isRight => palmerQuadrant == 1 || palmerQuadrant == 4;

  // ─── Tooth Metadata ───

  String get quadrantName {
    switch (palmerQuadrant) {
      case 1: return 'Upper Right';
      case 2: return 'Upper Left';
      case 3: return 'Lower Left';
      case 4: return 'Lower Right';
      default: return '';
    }
  }

  ToothShape get shape {
    switch (palmerNumber) {
      case 1: return ToothShape.centralIncisor;
      case 2: return ToothShape.lateralIncisor;
      case 3: return ToothShape.canine;
      case 4: return ToothShape.firstPremolar;
      case 5: return ToothShape.secondPremolar;
      case 6: return ToothShape.firstMolar;
      case 7: return ToothShape.secondMolar;
      case 8: return ToothShape.thirdMolar;
      default: return ToothShape.centralIncisor;
    }
  }

  String get toothTypeName {
    switch (palmerNumber) {
      case 1: return 'Central Incisor';
      case 2: return 'Lateral Incisor';
      case 3: return 'Canine';
      case 4: return 'First Premolar';
      case 5: return 'Second Premolar';
      case 6: return 'First Molar';
      case 7: return 'Second Molar';
      case 8: return 'Third Molar';
      default: return 'Unknown';
    }
  }

  String get fullName => '$quadrantName $toothTypeName';

  String get dentition => 'Permanent';

  /// Whether this tooth is an anterior tooth (incisor or canine)
  bool get isAnterior => palmerNumber <= 3;

  /// Palmer bracket character for display
  String get palmerBracketChar {
    switch (palmerQuadrant) {
      case 1: return '┘';
      case 2: return '└';
      case 3: return '┌';
      case 4: return '┐';
      default: return '';
    }
  }

  Tooth copyWith({int? number, ProcedureType? procedure}) {
    return Tooth(
      number: number ?? this.number,
      procedure: procedure ?? this.procedure,
    );
  }
}
