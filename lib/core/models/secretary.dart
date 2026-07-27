class Secretary {
  final int? id;
  final String name;
  final String phone;
  final String username;
  final String password;
  final bool isActive;
  final DateTime createdAt;

  Secretary({
    this.id,
    required this.name,
    this.phone = '',
    required this.username,
    required this.password,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'username': username,
      'password': password,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Secretary.fromMap(Map<String, dynamic> map) {
    return Secretary(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      username: map['username'],
      password: map['password'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Secretary copyWith({
    int? id,
    String? name,
    String? phone,
    String? username,
    String? password,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Secretary(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      username: username ?? this.username,
      password: password ?? this.password,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
