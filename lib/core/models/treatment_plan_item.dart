import 'package:flutter/material.dart';
import 'tooth.dart';

enum TreatmentPlanStatus {
  planned,
  scheduled,
  inProgress,
  waitingForLab,
  completed,
  cancelled,
}

class TreatmentPlanItem {
  final int? id;
  final int patientId;
  final int toothNumber; // Universal numbering 1-32
  final ProcedureType procedureType;
  final TreatmentPlanStatus status;
  final int currentVisit;
  final int totalVisits;
  final DateTime? nextVisitDate;
  final String doctorName;
  final double estimatedFee;
  final double paidAmount;
  final String notes;
  final DateTime createdAt;
  final DateTime? completedAt;

  TreatmentPlanItem({
    this.id,
    required this.patientId,
    required this.toothNumber,
    required this.procedureType,
    this.status = TreatmentPlanStatus.planned,
    this.currentVisit = 1,
    this.totalVisits = 1,
    this.nextVisitDate,
    this.doctorName = 'Dr. Ahmed',
    this.estimatedFee = 0.0,
    this.paidAmount = 0.0,
    this.notes = '',
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Tooth get tooth => Tooth(number: toothNumber, procedure: procedureType);

  String get palmerCode {
    final t = tooth;
    final quadPrefix = t.palmerQuadrant == 1 ? 'UR' : (t.palmerQuadrant == 2 ? 'UL' : (t.palmerQuadrant == 3 ? 'LL' : 'LR'));
    return '$quadPrefix${t.palmerNumber}';
  }

  String get palmerDisplay => '${tooth.palmerBracketChar}${tooth.palmerNumber} ($palmerCode)';

  String get procedureName {
    switch (procedureType) {
      case ProcedureType.restoration: return 'Composite Restoration';
      case ProcedureType.extraction: return 'Extraction';
      case ProcedureType.endo: return 'Root Canal (RCT)';
      case ProcedureType.implant: return 'Implant';
      case ProcedureType.crown: return 'Crown';
      case ProcedureType.veneer: return 'Veneer';
      case ProcedureType.bridge: return 'Bridge';
      case ProcedureType.none: default: return 'Checkup / Consultation';
    }
  }

  String get statusDisplay {
    switch (status) {
      case TreatmentPlanStatus.planned:
        return 'Planned';
      case TreatmentPlanStatus.scheduled:
        return 'Scheduled';
      case TreatmentPlanStatus.inProgress:
        return totalVisits > 1 ? 'Visit $currentVisit of $totalVisits (In Progress)' : 'In Progress';
      case TreatmentPlanStatus.waitingForLab:
        return 'Waiting for Lab';
      case TreatmentPlanStatus.completed:
        return 'Completed';
      case TreatmentPlanStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case TreatmentPlanStatus.planned:
        return const Color(0xFF1565C0); // Blue
      case TreatmentPlanStatus.scheduled:
        return const Color(0xFF00897B); // Teal
      case TreatmentPlanStatus.inProgress:
        return const Color(0xFFF57C00); // Amber/Orange
      case TreatmentPlanStatus.waitingForLab:
        return const Color(0xFF7B1FA2); // Purple
      case TreatmentPlanStatus.completed:
        return const Color(0xFF2E7D32); // Green
      case TreatmentPlanStatus.cancelled:
        return const Color(0xFF757575); // Grey
    }
  }

  IconData get statusIcon {
    switch (status) {
      case TreatmentPlanStatus.planned:
        return Icons.radio_button_unchecked;
      case TreatmentPlanStatus.scheduled:
        return Icons.event_note;
      case TreatmentPlanStatus.inProgress:
        return Icons.timelapse;
      case TreatmentPlanStatus.waitingForLab:
        return Icons.science;
      case TreatmentPlanStatus.completed:
        return Icons.check_circle;
      case TreatmentPlanStatus.cancelled:
        return Icons.cancel;
    }
  }

  double get remainingBalance {
    final rem = estimatedFee - paidAmount;
    return rem < 0 ? 0.0 : rem;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'tooth_number': toothNumber,
      'procedure_type': procedureType.name,
      'status': status.name,
      'current_visit': currentVisit,
      'total_visits': totalVisits,
      'next_visit_date': nextVisitDate?.toIso8601String(),
      'doctor_name': doctorName,
      'estimated_fee': estimatedFee,
      'paid_amount': paidAmount,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory TreatmentPlanItem.fromMap(Map<String, dynamic> map) {
    return TreatmentPlanItem(
      id: map['id'],
      patientId: map['patient_id'],
      toothNumber: map['tooth_number'],
      procedureType: ProcedureType.values.firstWhere(
        (e) => e.name == map['procedure_type'],
        orElse: () => ProcedureType.none,
      ),
      status: TreatmentPlanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TreatmentPlanStatus.planned,
      ),
      currentVisit: map['current_visit'] ?? 1,
      totalVisits: map['total_visits'] ?? 1,
      nextVisitDate: map['next_visit_date'] != null ? DateTime.tryParse(map['next_visit_date']) : null,
      doctorName: map['doctor_name'] ?? 'Dr. Ahmed',
      estimatedFee: (map['estimated_fee'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      completedAt: map['completed_at'] != null ? DateTime.tryParse(map['completed_at']) : null,
    );
  }

  TreatmentPlanItem copyWith({
    int? id,
    int? patientId,
    int? toothNumber,
    ProcedureType? procedureType,
    TreatmentPlanStatus? status,
    int? currentVisit,
    int? totalVisits,
    DateTime? nextVisitDate,
    String? doctorName,
    double? estimatedFee,
    double? paidAmount,
    String? notes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return TreatmentPlanItem(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      toothNumber: toothNumber ?? this.toothNumber,
      procedureType: procedureType ?? this.procedureType,
      status: status ?? this.status,
      currentVisit: currentVisit ?? this.currentVisit,
      totalVisits: totalVisits ?? this.totalVisits,
      nextVisitDate: nextVisitDate ?? this.nextVisitDate,
      doctorName: doctorName ?? this.doctorName,
      estimatedFee: estimatedFee ?? this.estimatedFee,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
