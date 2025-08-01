import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/family/presentation/cubit/family_cubit.dart';
import 'custom_button.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final nameController = TextEditingController(text: '');
  final balanceController = TextEditingController(text: '0.0');

  @override
  void dispose() {
    nameController.dispose();
    balanceController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (nameController.text.isNotEmpty) {
      final balance = double.tryParse(balanceController.text) ?? 0.0;
      context.read<FamilyCubit>().addFamilyUser(
        nameController.text,
        initialBalance: balance,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Member'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: balanceController,
            decoration: const InputDecoration(labelText: 'Initial Balance'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: 'Add',
          onPressed: _handleSubmit,
        ),
      ],
    );
  }
}
