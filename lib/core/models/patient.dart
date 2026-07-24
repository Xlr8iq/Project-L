class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final DateTime createdAt;
  final String phone;
  final String address;
  final String emergencyContact;
  final String emergencyPhone;
  final DateTime? dateOfBirth;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.createdAt,
    this.phone = '',
    this.address = '',
    this.emergencyContact = '',
    this.emergencyPhone = '',
    this.dateOfBirth,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      createdAt: DateTime.parse(map['created_at']),
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      emergencyContact: map['emergency_contact'] ?? '',
      emergencyPhone: map['emergency_phone'] ?? '',
      dateOfBirth: map['date_of_birth'] != null ? DateTime.tryParse(map['date_of_birth']) : null,
    );
  }
}
