class Appointment {
  final int? id;
  final int patientId;
  final DateTime dateTime;
  final String status;
  final String appointmentType;
  final String doctorName;
  final double consultationFee;
  final double paidAmount;
  final String notes;
  final String workPerformed;
  final String outcomes;
  final String medications;

  Appointment({
    this.id,
    required this.patientId,
    required this.dateTime,
    this.status = 'Scheduled',
    this.appointmentType = 'Consultation',
    this.doctorName = '',
    this.consultationFee = 0.0,
    this.paidAmount = 0.0,
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
      'appointment_type': appointmentType,
      'doctor_name': doctorName,
      'consultation_fee': consultationFee,
      'paid_amount': paidAmount,
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
      appointmentType: map['appointment_type'] ?? 'Consultation',
      doctorName: map['doctor_name'] ?? '',
      consultationFee: (map['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0.0,
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
    String? appointmentType,
    String? doctorName,
    double? consultationFee,
    double? paidAmount,
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
      appointmentType: appointmentType ?? this.appointmentType,
      doctorName: doctorName ?? this.doctorName,
      consultationFee: consultationFee ?? this.consultationFee,
      paidAmount: paidAmount ?? this.paidAmount,
      notes: notes ?? this.notes,
      workPerformed: workPerformed ?? this.workPerformed,
      outcomes: outcomes ?? this.outcomes,
      medications: medications ?? this.medications,
    );
  }
}
