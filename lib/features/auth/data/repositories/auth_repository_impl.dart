import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  
  // Default passwords for each role
  static const String _abiyePassword = '1234';
  static const String _tediPassword = 'Tediab1234';
  static const String _currentRoleKey = 'current_role';

  AuthRepositoryImpl(this._prefs);

  @override
  Future<Either<Failure, bool>> authenticateWithPassword({
    required UserRole role,
    required String password,
  }) async {
    try {
      final expectedPassword = role == UserRole.abiye ? _abiyePassword : _tediPassword;
      
      if (password == expectedPassword) {
        // Save the authenticated role
        await _prefs.setString(_currentRoleKey, role.name);
        return const Right(true);
      } else {
        return const Left(ValidationFailure('Invalid password'));
      }
    } catch (e) {
      return Left(UnknownFailure('Authentication failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserRole?>> getCurrentRole() async {
    try {
      final roleString = _prefs.getString(_currentRoleKey);
      if (roleString == null) {
        return const Right(null);
      }
      
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.abiye, // Default fallback
      );
      
      return Right(role);
    } catch (e) {
      return Left(UnknownFailure('Failed to get current role: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _prefs.remove(_currentRoleKey);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated(UserRole role) async {
    try {
      final currentRoleResult = await getCurrentRole();
      return currentRoleResult.fold(
        (failure) => Left(failure),
        (currentRole) => Right(currentRole == role),
      );
    } catch (e) {
      return Left(UnknownFailure('Authentication check failed: $e'));
    }
  }
}
