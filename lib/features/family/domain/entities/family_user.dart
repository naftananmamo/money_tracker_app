class FamilyUser {
  final String id;
  final String name;
  final double balance;
  final String? avatarUrl;
  final DateTime createdAt;

  const FamilyUser({
    required this.id,
    required this.name,
    required this.balance,
    this.avatarUrl,
    required this.createdAt,
  });

  FamilyUser copyWith({
    String? id,
    String? name,
    double? balance,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return FamilyUser(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
