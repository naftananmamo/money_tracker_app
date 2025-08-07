import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/family_user.dart';
import '../entities/user_transaction.dart';

abstract class FamilyRepository {
  // Family Users
  Stream<Either<Failure, List<FamilyUser>>> getFamilyUsers();
  Future<Either<Failure, void>> addFamilyUser(FamilyUser user);
  Future<Either<Failure, void>> updateFamilyUser(FamilyUser user);
  Future<Either<Failure, void>> deleteFamilyUser(String userId);
  
  // Transactions
  Stream<Either<Failure, List<UserTransaction>>> getTransactions({int? limit});
  Future<Either<Failure, void>> addTransaction(UserTransaction transaction);
  Future<Either<Failure, void>> updateUserBalance(String userId, double newBalance);
}
