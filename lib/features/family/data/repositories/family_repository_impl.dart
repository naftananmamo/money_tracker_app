import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/user_transaction.dart';
import '../../domain/repositories/family_repository.dart';
import '../models/family_user_model.dart';
import '../models/user_transaction_model.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FirebaseFirestore _firestore;

  FamilyRepositoryImpl(this._firestore);

  @override
  Stream<Either<Failure, List<FamilyUser>>> getFamilyUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      try {
        final users = snapshot.docs
            .map((doc) => FamilyUserModel.fromFirestore(doc))
            .cast<FamilyUser>()
            .toList();
        return Right(users);
      } catch (e) {
        return Left(ServerFailure('Failed to fetch users: $e'));
      }
    });
  }

  @override
  Future<Either<Failure, void>> addFamilyUser(FamilyUser user) async {
    try {
      final userModel = FamilyUserModel.fromEntity(user);
      await _firestore.collection('users').add(userModel.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateFamilyUser(FamilyUser user) async {
    try {
      final userModel = FamilyUserModel.fromEntity(user);
      await _firestore.collection('users').doc(user.id).update(userModel.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFamilyUser(String userId) async {
    try {
      // Also delete all transactions for this user
      final transactionsQuery = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      
      // Add user deletion to batch
      batch.delete(_firestore.collection('users').doc(userId));
      
      // Add transaction deletions to batch
      for (final doc in transactionsQuery.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete user: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<UserTransaction>>> getTransactions({int? limit}) {
    try {
      Query query = _firestore.collection('transactions').orderBy('createdAt', descending: true);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query.snapshots().map((snapshot) {
        try {
          final transactions = snapshot.docs
              .map((doc) => UserTransactionModel.fromFirestore(doc))
              .cast<UserTransaction>()
              .toList();
          return Right(transactions);
        } catch (e) {
          return Left(ServerFailure('Failed to parse transactions: $e'));
        }
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure('Failed to fetch transactions: $e')));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(UserTransaction transaction) async {
    try {
      final transactionModel = UserTransactionModel.fromEntity(transaction);
      
      final batch = _firestore.batch();
      
      // Add transaction
      final transactionRef = _firestore.collection('transactions').doc();
      batch.set(transactionRef, transactionModel.toMap());
      
      // Update user balance
      final userRef = _firestore.collection('users').doc(transaction.userId);
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        return const Left(ValidationFailure('User not found'));
      }
      
      final userData = userDoc.data()!;
      final currentBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = transaction.isAddition 
          ? currentBalance + transaction.amount
          : currentBalance - transaction.amount;
      
      batch.update(userRef, {'balance': newBalance});
      
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to add transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserBalance(String userId, double newBalance) async {
    try {
      await _firestore.collection('users').doc(userId).update({'balance': newBalance});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to update user balance: $e'));
    }
  }
}
