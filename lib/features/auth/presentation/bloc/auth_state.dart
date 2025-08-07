import 'package:equatable/equatable.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final UserRole role;

  const AuthSuccess(this.role);

  @override
  List<Object> get props => [role];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthCheckResult extends AuthState {
  final bool isAuthenticated;
  final UserRole role;

  const AuthCheckResult({
    required this.isAuthenticated,
    required this.role,
  });

  @override
  List<Object> get props => [isAuthenticated, role];
}
