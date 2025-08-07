import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_transaction.dart';

class UserTransactionModel extends UserTransaction {
  const UserTransactionModel({
    required String id,
    required String userId,
    required String userName,
    required double amount,
    required String description,
    required String reason,
    required bool isAddition,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          userName: userName,
          amount: amount,
          description: description,
          reason: reason,
          isAddition: isAddition,
          createdAt: createdAt,
        );

  factory UserTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTransactionModel(
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

  factory UserTransactionModel.fromEntity(UserTransaction transaction) {
    return UserTransactionModel(
      id: transaction.id,
      userId: transaction.userId,
      userName: transaction.userName,
      amount: transaction.amount,
      description: transaction.description,
      reason: transaction.reason,
      isAddition: transaction.isAddition,
      createdAt: transaction.createdAt,
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

  UserTransactionModel copyWith({
    String? id,
    String? userId,
    String? userName,
    double? amount,
    String? description,
    String? reason,
    bool? isAddition,
    DateTime? createdAt,
  }) {
    return UserTransactionModel(
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
}
