import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubits/admin_transaction_cubit.dart';
import '../cubits/admin_transaction_state.dart';

class UserMoneyDialogWidget extends StatefulWidget {
  const UserMoneyDialogWidget({Key? key}) : super(key: key);

  @override
  State<UserMoneyDialogWidget> createState() => _UserMoneyDialogWidgetState();
}

class _UserMoneyDialogWidgetState extends State<UserMoneyDialogWidget> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedUserId;
  bool _isAddition = true;

  @override
  void initState() {
    super.initState();
    context.read<AdminTransactionCubit>().loadUsers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminTransactionCubit, AdminTransactionState>(
      builder: (context, state) {
        List<Map<String, dynamic>> users = [];
        if (state is AdminUsersLoaded) {
          users = state.users;
        }

        return AlertDialog(
          title: const Text('Manage User Money'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select User'),
                  value: _selectedUserId,
                  items: users.map((user) {
                    return DropdownMenuItem<String>(
                      value: user['id'],
                      child: Text(user['name'] ?? user['email'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedUserId = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Add Money'),
                        value: true,
                        groupValue: _isAddition,
                        onChanged: (value) => setState(() => _isAddition = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Remove Money'),
                        value: false,
                        groupValue: _isAddition,
                        onChanged: (value) => setState(() => _isAddition = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amountText = _amountController.text.trim();
                final reason = _reasonController.text.trim();

                if (_selectedUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a user.')),
                  );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid amount.')),
                  );
                  return;
                }

                final adminEmail =
                    FirebaseAuth.instance.currentUser?.email ?? 'unknown@admin.com';

                if (_isAddition) {
                  context.read<AdminTransactionCubit>().addMoneyToUser(
                        _selectedUserId!,
                        amount,
                        reason,
                        adminEmail,
                      );
                } else {
                  context.read<AdminTransactionCubit>().removeMoneyFromUser(
                        _selectedUserId!,
                        amount,
                        reason,
                        adminEmail,
                      );
                }

                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
