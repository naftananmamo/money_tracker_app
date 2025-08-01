import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/user_transaction.dart';
import '../../domain/repositories/family_repository.dart';
import 'family_state.dart';

class FamilyCubit extends Cubit<FamilyState> {
  final FamilyRepository _repository;
  StreamSubscription<dynamic>? _usersSubscription;
  StreamSubscription<dynamic>? _transactionsSubscription;

  FamilyCubit(this._repository) : super(const FamilyInitial());

  void loadFamilyData() {
    emit(const FamilyLoading());

    // Cancel existing subscriptions to prevent multiple listeners
    _usersSubscription?.cancel();
    _transactionsSubscription?.cancel();

    // Listen to users stream
    _usersSubscription = _repository.getFamilyUsers().listen(
      (usersResult) {
        usersResult.fold(
          (failure) => emit(FamilyError(failure.message)),
          (users) {
            // Also listen to transactions
            _transactionsSubscription?.cancel(); // Cancel any existing transaction subscription
            _transactionsSubscription = _repository.getTransactions(limit: 20).listen(
              (transactionsResult) {
                transactionsResult.fold(
                  (failure) => emit(FamilyError(failure.message)),
                  (transactions) => emit(FamilyUsersLoaded(
                    users: users,
                    transactions: transactions,
                  )),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> addFamilyUser(String name, {double initialBalance = 0.0}) async {
    final user = FamilyUser(
      id: '', // Firestore will generate ID
      name: name,
      balance: initialBalance,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addFamilyUser(user);
    result.fold(
      (failure) => emit(FamilyError(failure.message)),
      (_) => emit(const FamilyOperationSuccess('User added successfully!')),
    );
  }

  Future<void> addMoney({
    required String userId,
    required String userName,
    required double amount,
    required String reason,
    String description = '',
  }) async {
    final transaction = UserTransaction(
      id: '', // Firestore will generate ID
      userId: userId,
      userName: userName,
      amount: amount,
      description: description,
      reason: reason,
      isAddition: true,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addTransaction(transaction);
    result.fold(
      (failure) => emit(FamilyError(failure.message)),
      (_) => emit(const FamilyOperationSuccess('Money added successfully!')),
    );
  }

  Future<void> subtractMoney({
    required String userId,
    required String userName,
    required double amount,
    required String reason,
    String description = '',
  }) async {
    final transaction = UserTransaction(
      id: '', // Firestore will generate ID
      userId: userId,
      userName: userName,
      amount: amount,
      description: description,
      reason: reason,
      isAddition: false,
      createdAt: DateTime.now(),
    );

    final result = await _repository.addTransaction(transaction);
    result.fold(
      (failure) => emit(FamilyError(failure.message)),
      (_) => emit(const FamilyOperationSuccess('Money subtracted successfully!')),
    );
  }

  Future<void> deleteFamilyUser(String userId) async {
    final result = await _repository.deleteFamilyUser(userId);
    result.fold(
      (failure) => emit(FamilyError(failure.message)),
      (_) => emit(const FamilyOperationSuccess('User deleted successfully!')),
    );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
