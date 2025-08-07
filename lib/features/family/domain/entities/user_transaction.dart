class UserTransaction {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String description;
  final String reason;
  final bool isAddition;
  final DateTime createdAt;

  const UserTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.reason,
    required this.isAddition,
    required this.createdAt,
  });

  UserTransaction copyWith({
    String? id,
    String? userId,
    String? userName,
    double? amount,
    String? description,
    String? reason,
    bool? isAddition,
    DateTime? createdAt,
  }) {
    return UserTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      isAddition: isAddition ?? this.isAddition,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
