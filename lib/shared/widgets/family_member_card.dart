import 'package:flutter/material.dart';
import '../../features/family/domain/entities/family_user.dart';

class FamilyMemberCard extends StatelessWidget {
  final FamilyUser user;
  final Color mainColor;
  final Color textColor;
  final bool isAbiye;
  final VoidCallback? onAddMoney;
  final VoidCallback? onSubtractMoney;

  const FamilyMemberCard({
    super.key,
    required this.user,
    required this.mainColor,
    required this.textColor,
    required this.isAbiye,
    this.onAddMoney,
    this.onSubtractMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mainColor,
          child: Text(
            user.name[0].toUpperCase(), 
            style: const TextStyle(color: Colors.white)
          ),
        ),
        title: Text(
          user.name, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: textColor
          )
        ),
        subtitle: Text(
          'Balance: \$${user.balance.toStringAsFixed(2)}', 
          style: TextStyle(
            color: textColor.withValues(alpha: 0.7)
          )
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAbiye) ...[
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: onAddMoney,
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: onSubtractMoney,
              ),
            ],
            Icon(
              user.balance >= 0 
                  ? Icons.trending_up 
                  : Icons.trending_down,
              color: user.balance >= 0 ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
