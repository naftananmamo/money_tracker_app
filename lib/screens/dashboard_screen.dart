import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_role.dart';
import '../models/family_user.dart';
import '../models/user_transaction.dart';
import '../utils/app_theme.dart';
import 'category_manager_screen.dart';
import 'role_selector_screen.dart';

class Dashboard extends StatefulWidget {
  final UserRole role;
  const Dashboard({super.key, required this.role});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _firestore = FirebaseFirestore.instance;
  List<FamilyUser> _users = [];
  List<UserTransaction> _transactions = [];
  FamilyUser? _selectedUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadTransactions();
  }

  void _loadUsers() {
    _firestore.collection('family_users').snapshots().listen((snapshot) {
      setState(() {
        _users = snapshot.docs.map((doc) => FamilyUser.fromFirestore(doc)).toList();
        _users.sort((a, b) => a.name.compareTo(b.name));
        if (_selectedUser == null && _users.isNotEmpty) {
          _selectedUser = _users.first;
        }
        _isLoading = false;
      });
    });
  }

  void _loadTransactions() {
    _firestore.collection('user_transactions')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _transactions = snapshot.docs.map((doc) => UserTransaction.fromFirestore(doc)).toList();
      });
    });
  }

  Future<void> _addUser() async {
    final nameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter family member name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                final newUser = FamilyUser(
                  id: '',
                  name: name,
                  balance: 0.0,
                  createdAt: DateTime.now(),
                );
                await _firestore.collection('family_users').add(newUser.toMap());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addTransaction(bool isAddition) async {
    if (_users.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add family members first')),
      );
      return;
    }

    final amountController = TextEditingController();
    final descController = TextEditingController();
    final reasonController = TextEditingController();
    FamilyUser? selectedUser = _selectedUser;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isAddition ? 'Add Money' : 'Subtract Money'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<FamilyUser>(
                value: selectedUser,
                decoration: const InputDecoration(labelText: 'Family Member'),
                items: _users.map((user) => DropdownMenuItem(
                  value: user,
                  child: Text('${user.name} (\$${user.balance.toStringAsFixed(2)})'),
                )).toList(),
                onChanged: (user) => setDialogState(() => selectedUser = user),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason',
                  hintText: isAddition ? 'e.g., Chores, Allowance' : 'e.g., Purchase, Spending',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'Additional details',
                ),
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
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                final reason = reasonController.text.trim();
                
                if (amount > 0 && selectedUser != null && reason.isNotEmpty) {
                  final newBalance = isAddition 
                      ? selectedUser!.balance + amount 
                      : selectedUser!.balance - amount;
                  
                  // Update user balance
                  await _firestore.collection('family_users').doc(selectedUser!.id).update({
                    'balance': newBalance,
                  });
                  
                  // Add transaction record
                  final transaction = UserTransaction(
                    id: '',
                    userId: selectedUser!.id,
                    userName: selectedUser!.name,
                    amount: amount,
                    description: descController.text.trim(),
                    reason: reason,
                    isAddition: isAddition,
                    createdAt: DateTime.now(),
                  );
                  
                  await _firestore.collection('user_transactions').add(transaction.toMap());
                  Navigator.pop(context);
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void _openCategoryManager() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryManager(role: widget.role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAbiye = widget.role == UserRole.abiye;
    final Color mainColor = isAbiye ? AppTheme.abiyeColor : AppTheme.tediColor;
    final Color accentColor = isAbiye ? AppTheme.abiyeAccent : const Color(0xFF263238);
    final Color bgColor = isAbiye ? AppTheme.abiyeBg : const Color(0xFFF5F7FA);
    final Color cardColor = isAbiye ? AppTheme.abiyeCard : Colors.white;
    final Color textColor = isAbiye ? accentColor : const Color(0xFF263238);
    
    final totalBalance = _users.fold(0.0, (sum, user) => sum + user.balance);
    
    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: bgColor),
              child: Text('Menu', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            ListTile(
              title: Text('Categories', style: TextStyle(color: textColor)),
              onTap: _openCategoryManager,
            ),
            if (!isAbiye)
              ListTile(
                title: Text('Manage Users', style: TextStyle(color: textColor)),
                onTap: _addUser,
              ),
            ListTile(
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RoleSelector())),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(widget.role == UserRole.tedi ? 'Family Manager' : 'Family Money', style: const TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('Total: \$${totalBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Family Members Section
                  Card(
                    color: cardColor,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Family Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
                              if (!isAbiye)
                                IconButton(
                                  icon: Icon(Icons.person_add, color: mainColor),
                                  onPressed: _addUser,
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _users.isEmpty
                              ? Text('No family members added yet', style: TextStyle(color: textColor))
                              : Column(
                                  children: _users.map((user) => Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: mainColor,
                                        child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                                      ),
                                      title: Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                      subtitle: Text('Balance: \$${user.balance.toStringAsFixed(2)}', style: TextStyle(color: textColor.withOpacity(0.7))),
                                      trailing: user.balance >= 0 
                                          ? const Icon(Icons.trending_up, color: Colors.green)
                                          : const Icon(Icons.trending_down, color: Colors.red),
                                    ),
                                  )).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons (Tedi only)
                  if (!isAbiye) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[50],
                              foregroundColor: Colors.green[900],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => _addTransaction(true),
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
                            onPressed: () => _addTransaction(false),
                            label: const Text('Subtract Money'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Recent Transactions
                  Card(
                    color: cardColor,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
                          const SizedBox(height: 16),
                          _transactions.isEmpty
                              ? Text('No transactions yet!', style: TextStyle(color: textColor))
                              : Column(
                                  children: _transactions.take(10).map((tx) => Card(
                                    color: Colors.white,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: tx.isAddition ? Colors.green : Colors.red,
                                        child: Icon(
                                          tx.isAddition ? Icons.add : Icons.remove,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        '${tx.isAddition ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)} - ${tx.userName}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Reason: ${tx.reason}', style: TextStyle(color: textColor.withOpacity(0.8))),
                                          if (tx.description.isNotEmpty)
                                            Text('Note: ${tx.description}', style: TextStyle(color: textColor.withOpacity(0.6))),
                                        ],
                                      ),
                                      trailing: Text(
                                        tx.createdAt.toString().substring(0, 16).replaceFirst('T', '\n'),
                                        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
