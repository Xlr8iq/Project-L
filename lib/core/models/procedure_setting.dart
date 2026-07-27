class ProcedureSetting {
  final int? id;
  final String name;
  final double defaultFee;
  final String currency;
  final int defaultVisits;
  final bool isActive;

  ProcedureSetting({
    this.id,
    required this.name,
    required this.defaultFee,
    this.currency = 'USD',
    this.defaultVisits = 1,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'default_fee': defaultFee,
      'currency': currency,
      'default_visits': defaultVisits,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory ProcedureSetting.fromMap(Map<String, dynamic> map) {
    return ProcedureSetting(
      id: map['id'],
      name: map['name'],
      defaultFee: (map['default_fee'] as num).toDouble(),
      currency: map['currency'] ?? 'USD',
      defaultVisits: map['default_visits'] ?? 1,
      isActive: (map['is_active'] ?? 1) == 1,
    );
  }

  ProcedureSetting copyWith({
    int? id,
    String? name,
    double? defaultFee,
    String? currency,
    int? defaultVisits,
    bool? isActive,
  }) {
    return ProcedureSetting(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultFee: defaultFee ?? this.defaultFee,
      currency: currency ?? this.currency,
      defaultVisits: defaultVisits ?? this.defaultVisits,
      isActive: isActive ?? this.isActive,
    );
  }
}
