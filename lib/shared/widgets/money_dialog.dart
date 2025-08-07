import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/family/domain/entities/family_user.dart';
import '../../features/family/presentation/cubit/family_cubit.dart';
import 'custom_button.dart';

class MoneyDialog extends StatefulWidget {
  final FamilyUser user;
  final bool isAddition;

  const MoneyDialog({
    super.key,
    required this.user,
    required this.isAddition,
  });

  @override
  State<MoneyDialog> createState() => _MoneyDialogState();
}

class _MoneyDialogState extends State<MoneyDialog> {
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final amount = double.tryParse(amountController.text);
    if (amount != null && amount > 0 && reasonController.text.isNotEmpty) {
      if (widget.isAddition) {
        context.read<FamilyCubit>().addMoney(
          userId: widget.user.id,
          userName: widget.user.name,
          amount: amount,
          reason: reasonController.text,
          description: descriptionController.text,
        );
      } else {
        context.read<FamilyCubit>().subtractMoney(
          userId: widget.user.id,
          userName: widget.user.name,
          amount: amount,
          reason: reasonController.text,
          description: descriptionController.text,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.isAddition ? 'Add' : 'Subtract'} Money - ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description (optional)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: widget.isAddition ? 'Add Money' : 'Subtract Money',
          onPressed: _handleSubmit,
        ),
      ],
    );
  }
}
