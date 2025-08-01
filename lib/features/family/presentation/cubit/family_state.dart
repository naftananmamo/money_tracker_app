import 'package:equatable/equatable.dart';
import '../../domain/entities/family_user.dart';
import '../../domain/entities/user_transaction.dart';

abstract class FamilyState extends Equatable {
  const FamilyState();

  @override
  List<Object?> get props => [];
}

class FamilyInitial extends FamilyState {
  const FamilyInitial();
}

class FamilyLoading extends FamilyState {
  const FamilyLoading();
}

class FamilyUsersLoaded extends FamilyState {
  final List<FamilyUser> users;
  final List<UserTransaction> transactions;

  const FamilyUsersLoaded({
    required this.users,
    required this.transactions,
  });

  @override
  List<Object> get props => [users, transactions];
}

class FamilyError extends FamilyState {
  final String message;

  const FamilyError(this.message);

  @override
  List<Object> get props => [message];
}

class FamilyOperationSuccess extends FamilyState {
  final String message;

  const FamilyOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
