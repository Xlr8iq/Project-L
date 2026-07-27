class Doctor {
  final int? id;
  final String name;
  final String specialty;
  final String phone;
  final String email;
  final String colorHex;
  final DateTime createdAt;

  Doctor({
    this.id,
    required this.name,
    this.specialty = 'General Dentist',
    this.phone = '',
    this.email = '',
    this.colorHex = '#1565C0',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'phone': phone,
      'email': email,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialty: map['specialty'] ?? 'General Dentist',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      colorHex: map['color_hex'] ?? '#1565C0',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Doctor copyWith({
    int? id,
    String? name,
    String? specialty,
    String? phone,
    String? email,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
