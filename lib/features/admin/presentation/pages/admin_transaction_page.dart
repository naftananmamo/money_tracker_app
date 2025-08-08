import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          FloatingActionButton.extended(
            heroTag: "manage_users",
            onPressed: () => _showUserManagementDialog(context),
            backgroundColor: Colors.blue[700],
            icon: const Icon(Icons.people, color: Colors.white, size: 28),
            label: const Text(
              'Manage Users',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: "manage_money",
            onPressed: () => _showUserMoneyDialog(context),
            backgroundColor: Colors.red[700],
            icon: const Icon(Icons.monetization_on, color: Colors.white, size: 28),
            label: const Text(
              'Manage User Money',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAdminAction)
                            Chip(
                              label: Text(
                                type == 'income' ? '+\$${amount.toStringAsFixed(2)}' : '-\$${amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: type == 'income' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: type == 'income' ? Colors.green[50] : Colors.red[50],
                            ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete_transaction') {
                                _showDeleteTransactionDialog(context, index, transaction);
                              } else if (value == 'delete_user' && transaction['userId'] != null) {
                                _showDeleteUserDialog(context, transaction['userId']);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete_transaction',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Delete Transaction'),
                                  ],
                                ),
                              ),
                              if (!isAdminAction && transaction['userId'] != null)
                                const PopupMenuItem(
                                  value: 'delete_user',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_forever, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete User'),
                                    ],
                                  ),
                                ),
                            ],
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

  void _showUserManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => UserManagementDialog(),
    );
  }

  void _showDeleteTransactionDialog(BuildContext context, int index, Map<String, dynamic> transaction) {
    final transactionId = transaction['id']; // Get the transaction ID
    
    if (transactionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete transaction: No ID found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?\n\n"${transaction['description'] ?? 'No description'}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AdminTransactionCubit>().deleteTransaction(transactionId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
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
            .where((user) => user['email'] != 'tedi@gmail.com') // Exclude admin
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

class UserManagementDialog extends StatefulWidget {
  @override
  _UserManagementDialogState createState() => _UserManagementDialogState();
}

class _UserManagementDialogState extends State<UserManagementDialog> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      setState(() {
        users = usersSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .where((user) => user['email'] != 'tedi@gmail.com') // Exclude admin
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
      title: const Text('User Management'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          children: [
            // Add User Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Add New User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            // Users List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            final email = user['email'] ?? 'Unknown';
                            final name = user['name'] ?? user['displayName'] ?? 'Unknown';
                            final balance = (user['balance'] ?? 0.0).toDouble();
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue[100],
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(email),
                                    Text(
                                      'Balance: \$${balance.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: balance >= 0 ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteUserDialog(user),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty ||
                  passwordController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.pop(context);
              await _addUser(
                nameController.text.trim(),
                emailController.text.trim(),
                passwordController.text.trim(),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Future<void> _addUser(String name, String email, String password) async {
    try {
      // Create user in Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          'email': email,
          'name': name,
          'balance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User $name added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload users
        _loadUsers();
      }
    } catch (e) {
      String errorMessage = 'Failed to add user';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email already exists';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    try {
      final userId = user['id'];
      
      // Delete user document from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .delete();

      // Note: We can't delete the user from Firebase Auth directly from client-side
      // This would require Firebase Admin SDK or Cloud Functions

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${user['name']} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload users
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
