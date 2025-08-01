import 'package:flutter/material.dart';
import '../../features/family/domain/entities/family_user.dart';

class UserSelectionDialog extends StatelessWidget {
  final bool isAddition;
  final List<FamilyUser> users;
  final Function(FamilyUser) onUserSelected;

  const UserSelectionDialog({
    super.key,
    required this.isAddition,
    required this.users,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select User to ${isAddition ? 'Add' : 'Subtract'} Money'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: users.map((user) => ListTile(
          leading: CircleAvatar(
            child: Text(user.name[0].toUpperCase()),
          ),
          title: Text(user.name),
          subtitle: Text('Balance: \$${user.balance.toStringAsFixed(2)}'),
          onTap: () {
            Navigator.pop(context);
            onUserSelected(user);
          },
        )).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
