import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/admin_transaction_cubit.dart';
import '../cubits/admin_transaction_state.dart';

class UserManagementDialogWidget extends StatefulWidget {
  // ignore: use_super_parameters
  const UserManagementDialogWidget({Key? key}) : super(key: key);

  @override
  State<UserManagementDialogWidget> createState() => _UserManagementDialogWidgetState();
}

class _UserManagementDialogWidgetState extends State<UserManagementDialogWidget> {
  @override
  void initState() {
    super.initState();
    context.read<AdminTransactionCubit>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminTransactionCubit, AdminTransactionState>(
      builder: (context, state) {
        if (state is AdminTransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminTransactionError) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(state.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        List<Map<String, dynamic>> users = [];
        if (state is AdminUsersLoaded) {
          users = state.users;
        }

        return AlertDialog(
          title: const Text('Manage Users'),
          content: SizedBox(
            width: 400,
            child: users.isEmpty
                ? const Text('No users found.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(user['name'] ?? user['email'] ?? 'Unknown'),
                          subtitle: Text('Email: ${user['email'] ?? 'Unknown'}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete User',
                                onPressed: () async {
                                  final confirm = await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Delete User"),
                                      content: Text("Are you sure you want to delete ${user['name'] ?? user['email']}?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                                        ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    context.read<AdminTransactionCubit>().deleteUser(user['id']);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.lock_reset, color: Colors.blue),
                                tooltip: 'Reset Password',
                                onPressed: () {
                                  context.read<AdminTransactionCubit>().resetUserPassword(user['email']);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
