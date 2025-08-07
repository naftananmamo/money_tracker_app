import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repos/admin_repo.dart';
import 'admin_transaction_state.dart';

class AdminTransactionCubit extends Cubit<AdminTransactionState> {
  final AdminRepo adminRepo;

  AdminTransactionCubit(this.adminRepo) : super(AdminTransactionInitial());

  Future<void> loadTransactions() async {
    emit(AdminTransactionLoading());
    
    try {
      final transactions = await adminRepo.getAllTransactions();
      emit(AdminTransactionLoaded(transactions));
    } catch (e) {
      emit(AdminTransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> deleteUser(String userId) async {
    emit(AdminTransactionLoading());
    
    try {
      final success = await adminRepo.deleteUser(userId);
      if (success) {
        emit(AdminActionSuccess('User deleted successfully'));
        // Reload transactions to show the new action
        await loadTransactions();
      } else {
        emit(AdminTransactionError('Failed to delete user'));
      }
    } catch (e) {
      emit(AdminTransactionError('Delete user failed: ${e.toString()}'));
    }
  }

  Future<void> resetUserPassword(String userId) async {
    emit(AdminTransactionLoading());
    
    try {
      final success = await adminRepo.resetUserPassword(userId, 'newpassword123');
      if (success) {
        emit(AdminActionSuccess('Password reset successfully'));
        // Reload transactions to show the new action
        await loadTransactions();
      } else {
        emit(AdminTransactionError('Failed to reset password'));
      }
    } catch (e) {
      emit(AdminTransactionError('Password reset failed: ${e.toString()}'));
    }
  }

  Future<void> logAdminAction(String action, String targetUser, Map<String, dynamic> details) async {
    try {
      await adminRepo.logAdminAction(action, targetUser, details);
      // Reload transactions to show the new action
      await loadTransactions();
    } catch (e) {
      emit(AdminTransactionError('Failed to log action: ${e.toString()}'));
    }
  }

  Future<void> loadUsers() async {
    emit(AdminTransactionLoading());
    
    try {
      final users = await adminRepo.getAllUsers();
      emit(AdminUsersLoaded(users));
    } catch (e) {
      emit(AdminTransactionError('Failed to load users: ${e.toString()}'));
    }
  }

  Future<void> addMoneyToUser(String userId, double amount, String reason, String adminEmail) async {
    emit(AdminTransactionLoading());
    
    try {
      final success = await adminRepo.addMoneyToUser(userId, amount, reason, adminEmail);
      if (success) {
        emit(AdminActionSuccess('Money added successfully'));
        // Reload transactions to show the new action
        await loadTransactions();
      } else {
        emit(AdminTransactionError('Failed to add money'));
      }
    } catch (e) {
      emit(AdminTransactionError('Add money failed: ${e.toString()}'));
    }
  }

  Future<void> removeMoneyFromUser(String userId, double amount, String reason, String adminEmail) async {
    emit(AdminTransactionLoading());
    
    try {
      final success = await adminRepo.removeMoneyFromUser(userId, amount, reason, adminEmail);
      if (success) {
        emit(AdminActionSuccess('Money removed successfully'));
        // Reload transactions to show the new action
        await loadTransactions();
      } else {
        emit(AdminTransactionError('Failed to remove money'));
      }
    } catch (e) {
      emit(AdminTransactionError('Remove money failed: ${e.toString()}'));
    }
  }
}