import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyUser {
  final String id;
  final String name;
  final double balance;
  final String? avatarUrl;
  final DateTime createdAt;

  FamilyUser({
    required this.id,
    required this.name,
    required this.balance,
    this.avatarUrl,
    required this.createdAt,
  });

  factory FamilyUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyUser(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      avatarUrl: data['avatarUrl'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'balance': balance,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

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
}
