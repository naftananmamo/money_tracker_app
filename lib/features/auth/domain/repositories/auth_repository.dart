import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_role.dart';

abstract class AuthRepository {
  /// Authenticate user with password for a specific role
  Future<Either<Failure, bool>> authenticateWithPassword({
    required UserRole role,
    required String password,
  });

  /// Get the current authenticated role (if any)
  Future<Either<Failure, UserRole?>> getCurrentRole();

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Check if user is authenticated for a specific role
  Future<Either<Failure, bool>> isAuthenticated(UserRole role);
}
