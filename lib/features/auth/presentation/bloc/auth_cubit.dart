import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_role.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthInitial());

  Future<void> authenticate(UserRole role, String password) async {
    emit(const AuthLoading());

    final result = await _authRepository.authenticateWithPassword(
      role: role,
      password: password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (success) => emit(AuthSuccess(role)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthLoggedOut()),
    );
  }

  Future<void> checkAuthentication(UserRole role) async {
    final result = await _authRepository.isAuthenticated(role);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (isAuthenticated) => emit(AuthCheckResult(
        isAuthenticated: isAuthenticated,
        role: role,
      )),
    );
  }

  Future<void> getCurrentRole() async {
    final result = await _authRepository.getCurrentRole();

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (role) {
        if (role != null) {
          emit(AuthSuccess(role));
        } else {
          emit(const AuthLoggedOut());
        }
      },
    );
  }
}
