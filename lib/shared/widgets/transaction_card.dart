import 'package:flutter/material.dart';
import '../../features/family/domain/entities/user_transaction.dart';

class TransactionCard extends StatelessWidget {
  final UserTransaction transaction;
  final Color textColor;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isAddition ? Colors.green : Colors.red,
          child: Icon(
            transaction.isAddition ? Icons.add : Icons.remove,
            color: Colors.white,
          ),
        ),
        title: Text(
          '${transaction.isAddition ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)} - ${transaction.userName}',
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: textColor
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reason: ${transaction.reason}', 
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8)
              )
            ),
            if (transaction.description.isNotEmpty)
              Text(
                'Note: ${transaction.description}', 
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6)
                )
              ),
          ],
        ),
        trailing: Text(
          transaction.createdAt.toString().substring(0, 16).replaceFirst('T', '\n'),
          style: TextStyle(
            color: textColor.withValues(alpha: 0.6), 
            fontSize: 12
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
