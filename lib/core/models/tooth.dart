enum ProcedureType { none, restoration, extraction, endo, implant }

class Tooth {
  final int number; // Universal numbering 1-32
  final ProcedureType procedure;

  Tooth({required this.number, this.procedure = ProcedureType.none});

  String get displayNumber {
    if (number >= 1 && number <= 8) return '${9 - number}';
    if (number >= 9 && number <= 16) return '${number - 8}';
    if (number >= 17 && number <= 24) return '${25 - number}';
    if (number >= 25 && number <= 32) return '${number - 24}';
    return '$number';
  }

  Tooth copyWith({int? number, ProcedureType? procedure}) {
    return Tooth(
      number: number ?? this.number,
      procedure: procedure ?? this.procedure,
    );
  }
}
