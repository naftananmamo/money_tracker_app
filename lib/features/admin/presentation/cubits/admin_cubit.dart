import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repos/admin_repo.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepo _adminRepo;

  AdminCubit(this._adminRepo) : super(AdminInitial());

  Future<void> loginAdmin(String email, String password) async {
    emit(AdminLoading());
    
    try {
      final success = await _adminRepo.loginAdmin(email, password);
      if (success) {
        emit(AdminLoginSuccess(email));
      } else {
        emit(AdminLoginFailure('Invalid credentials'));
      }
    } catch (e) {
      emit(AdminLoginFailure('Login failed: ${e.toString()}'));
    }
  }

  Future<void> logoutAdmin() async {
    emit(AdminLoading());
    
    try {
      emit(AdminLoggedOut());
    } catch (e) {
      emit(AdminLoginFailure('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> checkAdminStatus(String email) async {
    emit(AdminLoading());
    
    try {
      final isAdmin = await _adminRepo.isAdmin(email);
      if (isAdmin) {
        emit(AdminLoginSuccess(email));
      } else {
        emit(AdminInitial());
      }
    } catch (e) {
      emit(AdminLoginFailure('Status check failed: ${e.toString()}'));
    }
  }

  Future<void> createAdmin(String email, String password) async {
    emit(AdminLoading());
    
    try {
      final success = await _adminRepo.createAdmin(email, password);
      if (success) {
        emit(AdminLoginSuccess(email));
      } else {
        emit(AdminLoginFailure('Failed to create admin'));
      }
    } catch (e) {
      emit(AdminLoginFailure('Admin creation failed: ${e.toString()}'));
    }
  }

  Future<void> logAdminAction(String action, String targetUser, Map<String, dynamic> details) async {
    try {
      await _adminRepo.logAdminAction(action, targetUser, details);
    } catch (e) {
      emit(AdminLoginFailure('Failed to log action: ${e.toString()}'));
    }
  }
}
