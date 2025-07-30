// ✅ Updated Flutter App Code with Category and Task Management
// - Tedi (father) can manage categories and tasks
// - Abiye (daughter) can view categories and tasks, and see balance history
// - Firebase Firestore used for sync

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MoneyTrackerApp());
}

enum UserRole { tedi, abiye }

class FamilyUser {
  final String id;
  final String name;
  final double balance;
  final String? avatarUrl;
  final DateTime createdAt;

  FamilyUser({
    required this.id,
    required this.name,
    required this.balance,
    this.avatarUrl,
    required this.createdAt,
  });

  factory FamilyUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyUser(
      id: doc.id,
      name: data['name'] ?? '',
      balance: (data['balance'] ?? 0.0).toDouble(),
      avatarUrl: data['avatarUrl'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'balance': balance,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  FamilyUser copyWith({
    String? id,
    String? name,
    double? balance,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return FamilyUser(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserTransaction {
  final String id;
  final String userId;
  final String userName;
  final double amount;
  final String description;
  final String reason;
  final bool isAddition;
  final DateTime createdAt;

  UserTransaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.description,
    required this.reason,
    required this.isAddition,
    required this.createdAt,
  });

  factory UserTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      reason: data['reason'] ?? '',
      isAddition: data['isAddition'] ?? true,
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'amount': amount,
        'description': description,
        'reason': reason,
        'isAddition': isAddition,
        'createdAt': createdAt.toIso8601String(),
      };
}

class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});

  // Removed Firebase dependency
  Map<String, dynamic> toMap() => {
        'name': name,
      };
}

class Task {
  final String id;
  final String name;
  final double price;
  final DateTime createdAt;

  Task({required this.id, required this.name, required this.price, required this.createdAt});

  // Removed Firebase dependency  
  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'createdAt': createdAt.toIso8601String(),
      };
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abiye App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF1565C0), // deep blue
          onPrimary: Colors.white,
          secondary: Color(0xFF263238), // dark blue-grey
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF263238),
        ),
        scaffoldBackgroundColor: Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Comic Sans MS',
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const RoleSelector(),
    );
  }
}

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key});

  void _showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enter password for Tedi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text == 'Tediab1234') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard(role: UserRole.tedi)));
                } else {
                  setState(() => error = 'Incorrect password');
                }
              },
              child: const Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Light pink for landing page
    const Color landingBg = Color(0xFFFFE4F0);
    const Color tediColor = Color(0xFF1565C0);
    const Color abiyeColor = Color(0xFFFF69B4); // Vibrant pink
    // Custom icons for father and daughter
    const IconData fatherIcon = Icons.family_restroom;
    const IconData daughterIcon = Icons.face_4;
    return Scaffold(
      backgroundColor: landingBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Who are you?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: abiyeColor)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(fatherIcon, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: tediColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showPasswordDialog(context),
              label: const Text('Tedi', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(daughterIcon, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: abiyeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard(role: UserRole.abiye))),
              label: const Text('Abiye ', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}

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
    final Color mainColor = isAbiye ? const Color(0xFFFF69B4) : const Color(0xFF1565C0);
    final Color accentColor = isAbiye ? const Color(0xFFFF1493) : const Color(0xFF263238);
    final Color bgColor = isAbiye ? const Color(0xFFFFE4F0) : const Color(0xFFF5F7FA);
    final Color cardColor = isAbiye ? const Color(0xFFFFB6E6) : Colors.white;
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
                                          ? Icon(Icons.trending_up, color: Colors.green)
                                          : Icon(Icons.trending_down, color: Colors.red),
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

// Custom hoverable arrow button for Abiye to open CategoryManager
class _AbiyeCategoryHoverButton extends StatefulWidget {
  final VoidCallback onHover;
  final Color mainColor;
  const _AbiyeCategoryHoverButton({required this.onHover, required this.mainColor});

  @override
  State<_AbiyeCategoryHoverButton> createState() => _AbiyeCategoryHoverButtonState();
}

class _AbiyeCategoryHoverButtonState extends State<_AbiyeCategoryHoverButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        widget.onHover();
      },
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _hovering ? widget.mainColor.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.arrow_forward_ios, color: widget.mainColor, size: 28),
      ),
    );
  }
}

class CategoryManager extends StatefulWidget {
  final UserRole role;
  const CategoryManager({super.key, required this.role});

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  final _firestore = FirebaseFirestore.instance;
  // Local storage instead of Firebase
  List<Category> _categories = [
    Category(id: '1', name: 'Chores'),
    Category(id: '2', name: 'School Tasks'),
    Category(id: '3', name: 'Extra Activities'),
  ];
  String? _selectedCategoryId = '1';
  
  // Sample tasks with local storage
  Map<String, List<Task>> _tasksByCategory = {
    '1': [
      Task(id: '1', name: 'Clean room', price: 5.0, createdAt: DateTime.now()),
      Task(id: '2', name: 'Do dishes', price: 3.0, createdAt: DateTime.now()),
      Task(id: '3', name: 'Take out trash', price: 2.0, createdAt: DateTime.now()),
    ],
    '2': [
      Task(id: '4', name: 'Homework completed', price: 10.0, createdAt: DateTime.now()),
      Task(id: '5', name: 'Study for test', price: 15.0, createdAt: DateTime.now()),
    ],
    '3': [
      Task(id: '6', name: 'Help with groceries', price: 5.0, createdAt: DateTime.now()),
      Task(id: '7', name: 'Read a book', price: 8.0, createdAt: DateTime.now()),
    ],
  };

  List<Task> get _tasks => _tasksByCategory[_selectedCategoryId] ?? [];

  @override
  void initState() {
    super.initState();
    // No Firebase setup needed
  }

  void _selectCategory(String categoryId) {
    setState(() => _selectedCategoryId = categoryId);
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final newId = (_categories.length + 1).toString();
                  _categories.add(Category(id: newId, name: name));
                  _tasksByCategory[newId] = [];
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<void> _editCategory(Category category) async {
    final controller = TextEditingController(text: category.name);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Category Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  final index = _categories.indexWhere((c) => c.id == category.id);
                  if (index != -1) {
                    _categories[index] = Category(id: category.id, name: name);
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    setState(() {
      _categories.removeWhere((c) => c.id == category.id);
      _tasksByCategory.remove(category.id);
      if (_selectedCategoryId == category.id) {
        _selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
      }
    });
  }

  Future<void> _addTask() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Task Name')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              if (name.isNotEmpty && _selectedCategoryId != null) {
                await _firestore.collection('categories').doc(_selectedCategoryId!).collection('tasks').add({
                  'name': name,
                  'price': price,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<void> _editTask(Task task) async {
    final nameController = TextEditingController(text: task.name);
    final priceController = TextEditingController(text: task.price.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Task Name')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0.0;
              if (name.isNotEmpty && _selectedCategoryId != null) {
                await _firestore.collection('categories').doc(_selectedCategoryId!).collection('tasks').doc(task.id).update({
                  'name': name,
                  'price': price,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          )
        ],
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    await _firestore.collection('categories').doc(_selectedCategoryId!).collection('tasks').doc(task.id).delete();
  }

  // Add state variable for hover text
  bool _showManagerText = false;

  @override
  Widget build(BuildContext context) {
    final isTedi = widget.role == UserRole.tedi;
    int selectedIndex = _categories.indexWhere((c) => c.id == _selectedCategoryId);
    // User-friendly, eye-comfortable color palette
    // Vibrant pink theme for Abiye
    final Color mainColor = isTedi
        ? const Color(0xFF1976D2) // Blue for Tedi
        : const Color(0xFFFF1493); // Vibrant pink for Abiye
    final Color secondaryColor = isTedi
        ? const Color(0xFF1565C0) // Slightly darker for Tedi
        : const Color(0xFFFF69B4); // Hot pink accent for Abiye
    final Color gradientStart = isTedi
        ? const Color(0xFFE3F2FD) // Soft blue for Tedi
        : const Color(0xFFFFE4F0); // Vibrant pink bg for Abiye
    final Color gradientEnd = isTedi
        ? const Color(0xFF90CAF9) // Soft blue for Tedi
        : const Color(0xFFFFB6E6); // Vibrant pink for Abiye
    final Color cardColor = isTedi
        ? Colors.white
        : const Color(0xFFFFB6E6); // Vibrant pink card for Abiye
    final Color selectedCardColor = isTedi
        ? mainColor.withOpacity(0.12)
        : mainColor.withOpacity(0.22); // Vibrant pink highlight for Abiye
    final Color textColor = isTedi
        ? const Color(0xFF222831)
        : Colors.black; // Black text for Abiye
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            _CategoryManagerHoverArrow(mainColor: mainColor),
            const SizedBox(width: 8),
            Expanded(
              child: MouseRegion(
                onEnter: (event) => setState(() => _showManagerText = true),
                onExit: (event) => setState(() => _showManagerText = false),
                child: AnimatedOpacity(
                  opacity: _showManagerText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text('Category Manager', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                ),
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (isTedi)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 2,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.add),
                label: const Text('New Category'),
                onPressed: _addCategory,
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStart, gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor.withOpacity(0.98),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: mainColor.withOpacity(0.10), blurRadius: 16)],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ..._categories.asMap().entries.map((entry) {
                      final i = entry.key;
                      final c = entry.value;
                      final selected = i == selectedIndex;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
                        child: Material(
                          color: selected ? selectedCardColor : cardColor,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _selectCategory(c.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              child: Column(
                                children: [
                                  Icon(Icons.book, color: selected ? mainColor : secondaryColor),
                                  const SizedBox(height: 6),
                                  Text(
                                    c.name,
                                    style: TextStyle(
                                      color: selected ? mainColor : textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCategoryId != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Text(
                              'Tasks in "${_categories.firstWhere((c) => c.id == _selectedCategoryId).name}"',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: mainColor),
                            ),
                            if (isTedi)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cardColor,
                                  foregroundColor: mainColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 1,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                onPressed: () => _editCategory(_categories.firstWhere((c) => c.id == _selectedCategoryId)),
                              ),
                            if (isTedi)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cardColor,
                                  foregroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 1,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                icon: const Icon(Icons.delete),
                                label: const Text('Delete'),
                                onPressed: () => _deleteCategory(_categories.firstWhere((c) => c.id == _selectedCategoryId)),
                              ),
                            if (isTedi)
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  elevation: 2,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Task'),
                                onPressed: _addTask,
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _tasks.isEmpty
                          ? Center(child: Text('No tasks yet!', style: TextStyle(color: mainColor, fontSize: 18)))
                          : ListView(
                              children: _tasks.map((task) => Card(
                                    color: cardColor,
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      leading: CircleAvatar(
                                        backgroundColor: mainColor.withOpacity(0.15),
                                        child: Icon(Icons.task, color: mainColor),
                                      ),
                                      title: Text(task.name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                      subtitle: Text('\$${task.price.toStringAsFixed(2)}', style: TextStyle(color: textColor.withOpacity(0.7))),
                                      trailing: isTedi
                                          ? Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit, color: mainColor),
                                                  onPressed: () => _editTask(task),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                                  onPressed: () => _deleteTask(task),
                                                ),
                                              ],
                                            )
                                          : null,
                                    ),
                                  )).toList(),
                            ),
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

// Arrow icon for CategoryManager AppBar, shows text only on hover
class _CategoryManagerHoverArrow extends StatefulWidget {
  final Color mainColor;
  const _CategoryManagerHoverArrow({required this.mainColor});

  @override
  State<_CategoryManagerHoverArrow> createState() => _CategoryManagerHoverArrowState();
}

class _CategoryManagerHoverArrowState extends State<_CategoryManagerHoverArrow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Row(
        children: [
          Icon(Icons.arrow_forward_ios, color: widget.mainColor, size: 28),
          AnimatedOpacity(
            opacity: _hovering ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Padding(
              padding: const EdgeInsets.only(left: 6.0),
              child: Text('Category Manager', style: TextStyle(fontWeight: FontWeight.bold, color: widget.mainColor)),
            ),
          ),
        ],
      ),
    );
  }
}
