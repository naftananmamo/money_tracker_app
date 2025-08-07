import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Create user with email and password
  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  /// Check if user is logged in with Firebase
  Future<Either<Failure, bool>> isLoggedIn();

  /// Get current user email
  Future<Either<Failure, String?>> getCurrentUserEmail();
}
