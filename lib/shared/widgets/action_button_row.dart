import 'package:flutter/material.dart';

class ActionButtonRow extends StatelessWidget {
  final VoidCallback onAddMoney;
  final VoidCallback onSubtractMoney;

  const ActionButtonRow({
    super.key,
    required this.onAddMoney,
    required this.onSubtractMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[900],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: onAddMoney,
            label: const Text('Add Money'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[900],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: onSubtractMoney,
            label: const Text('Subtract Money'),
          ),
        ),
      ],
    );
  }
}
