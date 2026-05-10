class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final DateTime createdAt;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.createdAt,
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
    );
  }
}
