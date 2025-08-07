import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubits/admin_transaction_cubit.dart';
import '../cubits/admin_transaction_state.dart';
import '../../../../utils/app_theme.dart';

class AdminTransactionPage extends StatefulWidget {
  const AdminTransactionPage({super.key});

  @override
  State<AdminTransactionPage> createState() => _AdminTransactionPageState();
}

class _AdminTransactionPageState extends State<AdminTransactionPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminTransactionCubit>().loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.landingBg,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AdminTransactionCubit>().loadTransactions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "cleanup",
            onPressed: _showCleanupDialog,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.cleaning_services, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "manage_money",
            onPressed: () => _showUserMoneyDialog(context),
            backgroundColor: Colors.red[700],
            child: const Icon(Icons.monetization_on, color: Colors.white),
          ),
        ],
      ),
      body: BlocListener<AdminTransactionCubit, AdminTransactionState>(
        listener: (context, state) {
          if (state is AdminActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdminTransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AdminTransactionCubit, AdminTransactionState>(
          builder: (context, state) {
            if (state is AdminTransactionLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is AdminTransactionError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AdminTransactionCubit>().loadTransactions();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is AdminTransactionLoaded) {
              final transactions = state.transactions;
              
              if (transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  final isAdminAction = transaction['adminAction'] == true;
                  final amount = transaction['amount']?.toDouble() ?? 0.0;
                  final description = transaction['description'] ?? 'No description';
                  final type = transaction['type'] ?? 'unknown';
                  final adminEmail = transaction['adminEmail'] ?? 'Unknown';
                  final category = transaction['category'] ?? 'General';
                  
                  // Create a meaningful title based on the transaction data
                  String title;
                  if (isAdminAction) {
                    if (type == 'income') {
                      title = 'Added \$${amount.toStringAsFixed(2)} to user';
                    } else if (type == 'expense') {
                      title = 'Removed \$${amount.toStringAsFixed(2)} from user';
                    } else {
                      title = description;
                    }
                  } else {
                    title = description;
                  }
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAdminAction 
                          ? (type == 'income' ? Colors.green[100] : Colors.red[100])
                          : Colors.blue[100],
                        child: Icon(
                          isAdminAction 
                            ? (type == 'income' ? Icons.add_circle : Icons.remove_circle)
                            : Icons.receipt,
                          color: isAdminAction 
                            ? (type == 'income' ? Colors.green : Colors.red)
                            : Colors.blue,
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (transaction['userName'] != null)
                            Text('User: ${transaction['userName']} (${transaction['userEmail'] ?? 'Unknown'})'),
                          if (isAdminAction && adminEmail != 'Unknown')
                            Text('Admin: $adminEmail'),
                          if (description != title)
                            Text('Reason: $description'),
                          Text('Category: $category'),
                          if (transaction['timestamp'] != null)
                            Text(
                              'Time: ${_formatTimestamp(transaction['timestamp'])}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: isAdminAction 
                        ? Chip(
                            label: Text(
                              type == 'income' ? '+\$${amount.toStringAsFixed(2)}' : '-\$${amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: type == 'income' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: type == 'income' ? Colors.green[50] : Colors.red[50],
                          )
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete' && transaction['userId'] != null) {
                                _showDeleteUserDialog(context, transaction['userId']);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete User'),
                                  ],
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(
              child: Text('Welcome to Admin Panel'),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteUserDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminTransactionCubit>().deleteUser(userId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return 'No date';
      
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Invalid date';
      }
      
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  void _showUserMoneyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => UserMoneyDialog(),
    );
  }

  void _showCleanupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Up Mock Data'),
        content: const Text(
          'This will remove all sample/mock transactions from the database. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cleanupMockData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clean Up', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupMockData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cleaning up ALL mock/sample data...'),
          duration: Duration(seconds: 2),
        ),
      );

      final firestore = FirebaseFirestore.instance;
      
      // Get all transactions
      final transactionsSnapshot = await firestore.collection('transactions').get();
      
      // Delete transactions that look like mock data - expanded detection
      int deletedCount = 0;
      final mockDescriptions = [
        'Coffee Shop',
        'Salary Deposit', 
        'Grocery Shopping',
        'Sample Transaction',
        'Test Transaction',
        'Gas Station',
        'Restaurant',
        'Online Purchase',
        'ATM Withdrawal',
        'Bank Transfer',
        'Utility Bill',
        'Rent Payment',
        'Freelance Payment',
        'Investment Return',
        'Gift',
        'Refund',
        'Morning Coffee',
        'Lunch',
        'Dinner',
        'Subscription',
        'Shopping',
        'Entertainment',
        'Transportation',
        'Healthcare',
        'Education',
        'Insurance',
        'Maintenance',
        'Office Supplies',
        'Parking',
        'Taxi',
        'Food & Drink',
        'Travel',
        'Hotel',
        'Flight',
        'Example',
        'Demo',
        'Sample',
        'Mock',
        'Test',
      ];

      // Also check for common mock amounts
      final mockAmounts = [10.0, 25.0, 50.0, 75.0, 100.0, 150.0, 200.0, 250.0, 300.0, 500.0, 1000.0, 1500.0, 2000.0, 2500.0, 3000.0];
      
      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final description = data['description'] ?? '';
        final amount = data['amount']?.toDouble() ?? 0.0;
        
        // Check if it's mock data by description or amount
        bool isMockData = mockDescriptions.any((mock) => description.toLowerCase().contains(mock.toLowerCase())) ||
                         mockAmounts.contains(amount);
        
        if (isMockData) {
          await doc.reference.delete();
          deletedCount++;
        }
      }

      // Also clean up any test users
      final usersSnapshot = await firestore.collection('users').get();
      int deletedUsers = 0;
      final testEmails = [
        'user1@example.com',
        'user2@example.com', 
        'user3@example.com',
        'john.doe@example.com',
        'jane.smith@example.com',
        'bob.johnson@example.com',
        'alice.wilson@example.com',
        'test@example.com',
        'example@example.com',
        'demo@example.com',
        'sample@example.com',
      ];
      
      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final email = data['email'] ?? '';
        
        if (testEmails.contains(email.toLowerCase())) {
          await doc.reference.delete();
          deletedUsers++;
        }
      }

      // Reload transactions to update the display
      context.read<AdminTransactionCubit>().loadTransactions();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully deleted $deletedCount mock transactions and $deletedUsers test users'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cleaning up data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class UserMoneyDialog extends StatefulWidget {
  @override
  _UserMoneyDialogState createState() => _UserMoneyDialogState();
}

class _UserMoneyDialogState extends State<UserMoneyDialog> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? selectedUser;
  String? selectedUserId;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  bool isLoading = true;
  bool isAddMoney = true; // true for add, false for remove

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      // Get users from Firestore directly since we need user info
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      setState(() {
        users = usersSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
        isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading users: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isAddMoney ? 'Add Money to User' : 'Remove Money from User'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add/Remove toggle
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isAddMoney = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAddMoney ? Colors.green : Colors.grey[300],
                      foregroundColor: isAddMoney ? Colors.white : Colors.black,
                    ),
                    child: const Text('Add Money'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => isAddMoney = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !isAddMoney ? Colors.red : Colors.grey[300],
                      foregroundColor: !isAddMoney ? Colors.white : Colors.black,
                    ),
                    child: const Text('Remove Money'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // User selection
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text('Loading users...'),
                  ],
                ),
              )
            else if (users.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No users found. Users will appear here when they register.',
                  style: TextStyle(color: Colors.orange),
                ),
              )
            else
              DropdownButtonFormField<String>(
                value: selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Select User',
                  border: OutlineInputBorder(),
                ),
                hint: Text('Choose from ${users.length} users'),
                items: users.map((user) {
                  final email = user['email'] ?? 'Unknown';
                  final displayName = user['displayName'] ?? user['name'] ?? email.split('@')[0];
                  return DropdownMenuItem<String>(
                    value: user['id'],
                    child: Text('$displayName ($email)'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
                    // Find the selected user by ID
                    selectedUser = users.firstWhere(
                      (user) => user['id'] == value,
                      orElse: () => {},
                    );
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a user';
                  }
                  return null;
                },
              ),
            
            const SizedBox(height: 16),
            
            // Amount input
            TextFormField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount (\$)',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  isAddMoney ? Icons.add : Icons.remove,
                  color: isAddMoney ? Colors.green : Colors.red,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            
            const SizedBox(height: 16),
            
            // Reason input
            TextFormField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitTransaction,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAddMoney ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(isAddMoney ? 'Add Money' : 'Remove Money'),
        ),
      ],
    );
  }

  void _submitTransaction() {
    if (selectedUser == null || selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason')),
      );
      return;
    }

    Navigator.pop(context);

    final adminCubit = context.read<AdminTransactionCubit>();
    const adminEmail = 'tedi@gmail.com'; // Should get this from current admin session

    if (isAddMoney) {
      adminCubit.addMoneyToUser(
        selectedUserId!,
        amount,
        reasonController.text.trim(),
        adminEmail,
      );
    } else {
      adminCubit.removeMoneyFromUser(
        selectedUserId!,
        amount,
        reasonController.text.trim(),
        adminEmail,
      );
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}
