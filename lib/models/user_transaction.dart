import 'package:cloud_firestore/cloud_firestore.dart';

class UserTransaction {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String description;
  final String reason;
  final bool isAddition;
  final DateTime createdAt;

  UserTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.reason,
    required this.isAddition,
    required this.createdAt,
  });

  factory UserTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      reason: data['reason'] ?? '',
      isAddition: data['isAddition'] ?? true,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'description': description,
        'reason': reason,
        'isAddition': isAddition,
        'createdAt': createdAt.toIso8601String(),
      };
}
