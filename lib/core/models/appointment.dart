class Appointment {
  final int? id;
  final int patientId;
  final DateTime dateTime;
  final String status;
  final String notes;
  final String workPerformed;
  final String outcomes;
  final String medications;

  Appointment({
    this.id,
    required this.patientId,
    required this.dateTime,
    this.status = 'Scheduled',
    this.notes = '',
    this.workPerformed = '',
    this.outcomes = '',
    this.medications = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date_time': dateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'work_performed': workPerformed,
      'outcomes': outcomes,
      'medications': medications,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patient_id'],
      dateTime: DateTime.parse(map['date_time']),
      status: map['status'] ?? 'Scheduled',
      notes: map['notes'] ?? '',
      workPerformed: map['work_performed'] ?? '',
      outcomes: map['outcomes'] ?? '',
      medications: map['medications'] ?? '',
    );
  }

  Appointment copyWith({
    int? id,
    int? patientId,
    DateTime? dateTime,
    String? status,
    String? notes,
    String? workPerformed,
    String? outcomes,
    String? medications,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      workPerformed: workPerformed ?? this.workPerformed,
      outcomes: outcomes ?? this.outcomes,
      medications: medications ?? this.medications,
    );
  }
}
