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
        emit(AdminLoginFailure('Invalid credentials or not an admin user'));
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      
      // Provide more specific error messages for common issues
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No user found with this email address';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Please try again later';
      } else {
        errorMessage = 'Login failed. Please check your credentials';
      }
      
      emit(AdminLoginFailure(errorMessage));
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

  Future<void> logAdminAction(String action, String targetUser, Map<String, dynamic> details) async {
    try {
      await _adminRepo.logAdminAction(action, targetUser, details);
    } catch (e) {
      emit(AdminLoginFailure('Failed to log action: ${e.toString()}'));
    }
  }
}
