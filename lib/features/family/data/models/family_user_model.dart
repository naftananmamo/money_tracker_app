import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/family_user.dart';

class FamilyUserModel extends FamilyUser {
  const FamilyUserModel({
    required String id,
    required String name,
    required double balance,
    String? avatarUrl,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          balance: balance,
          avatarUrl: avatarUrl,
          createdAt: createdAt,
        );

  factory FamilyUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyUserModel(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      avatarUrl: data['avatarUrl'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory FamilyUserModel.fromEntity(FamilyUser user) {
    return FamilyUserModel(
      id: user.id,
      name: user.name,
      balance: user.balance,
      avatarUrl: user.avatarUrl,
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'balance': balance,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  FamilyUserModel copyWith({
    String? id,
    String? name,
    double? balance,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return FamilyUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
