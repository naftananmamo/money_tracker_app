abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoginSuccess extends AdminState {
  final String email;
  AdminLoginSuccess(this.email);
}

class AdminLoginFailure extends AdminState {
  final String error;
  AdminLoginFailure(this.error);
}

class AdminLoggedOut extends AdminState {}
