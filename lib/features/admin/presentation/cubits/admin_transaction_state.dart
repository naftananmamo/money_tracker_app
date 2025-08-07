abstract class AdminTransactionState {}

class AdminTransactionInitial extends AdminTransactionState {}

class AdminTransactionLoading extends AdminTransactionState {}

class AdminTransactionLoaded extends AdminTransactionState {
  final List<Map<String, dynamic>> transactions;
  AdminTransactionLoaded(this.transactions);
}

class AdminUsersLoaded extends AdminTransactionState {
  final List<Map<String, dynamic>> users;
  AdminUsersLoaded(this.users);
}

class AdminTransactionError extends AdminTransactionState {
  final String message;
  AdminTransactionError(this.message);
}

class AdminActionSuccess extends AdminTransactionState {
  final String message;
  AdminActionSuccess(this.message);
}
