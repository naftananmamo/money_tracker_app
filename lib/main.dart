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

class Category {
  final String id;
  final String name;
  Category({required this.id, required this.name});

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'],
    );
  }

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

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      name: data['name'],
      price: (data['price'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

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
          background: Color(0xFFF5F7FA), // very light blue/grey
          onBackground: Color(0xFF263238),
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
  double _balance = 0.0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _listenToBalance();
  }

  void _listenToBalance() {
    _firestore.collection('money').doc('shared_money_data').snapshots().listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _balance = (data['balance'] ?? 0.0).toDouble();
          _transactions = (data['transactions'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        });
      }
    });
  }

  Future<void> _addTransaction(bool isAddition) async {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAddition ? 'Add Money' : 'Subtract Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              final desc = descController.text.trim();
              if (amount > 0) {
                final newBalance = isAddition ? _balance + amount : _balance - amount;
                final newTx = {
                  'amount': amount,
                  'description': desc,
                  'date': DateTime.now().toIso8601String(),
                  'isAddition': isAddition,
                };
                final newTransactions = [newTx, ..._transactions];
                await _firestore.collection('money').doc('shared_money_data').set({
                  'balance': newBalance,
                  'transactions': newTransactions,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Confirm'),
          )
        ],
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
    // final isTedi = widget.role == UserRole.tedi; // Unused variable removed
    final bool isAbiye = widget.role == UserRole.abiye;
    // Pink theme for Abiye's dashboard
    final Color mainColor = isAbiye ? const Color(0xFFFF69B4) : const Color(0xFF1565C0); // Pink for Abiye, blue for Tedi
    final Color accentColor = isAbiye ? const Color(0xFFFF1493) : const Color(0xFF263238); // Deeper pink accent for Abiye
    final Color bgColor = isAbiye ? const Color(0xFFFFE4F0) : const Color(0xFFF5F7FA); // Pink bg for Abiye
    final Color cardColor = isAbiye ? const Color(0xFFFFB6E6) : Colors.white; // Pink card for Abiye
    final Color textColor = isAbiye ? accentColor : const Color(0xFF263238);
    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu', style: TextStyle(color: mainColor, fontWeight: FontWeight.bold, fontSize: 20)),
              decoration: BoxDecoration(color: bgColor),
            ),
            ListTile(
              title: Text('Categories', style: TextStyle(color: textColor)),
              onTap: _openCategoryManager,
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
        title: Text(widget.role == UserRole.tedi ? 'Tedi Dashboard' : 'Abiye Dashboard', style: const TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text('Balance: \$${_balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Current Balance', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainColor)),
            const SizedBox(height: 12),
            Card(
              color: cardColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                child: Text(
                  '\$${_balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: mainColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!isAbiye)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[50], foregroundColor: Colors.green[900]),
                    onPressed: () => _addTransaction(true),
                    label: const Text('Add Money'),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red[900]),
                    onPressed: () => _addTransaction(false),
                    label: const Text('Subtract Money'),
                  ),
                ],
              ),
            const SizedBox(height: 32),
            Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            Expanded(
              child: _transactions.isEmpty
                  ? Text('No transactions yet!', style: TextStyle(color: textColor))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, i) {
                        final tx = _transactions[i];
                        return ListTile(
                          leading: Icon(
                            tx['isAddition'] == true ? Icons.add : Icons.remove,
                            color: tx['isAddition'] == true ? Colors.green : Colors.red,
                          ),
                          title: Text((tx['isAddition'] == true ? '+ ' : '- ') + '\$${(tx['amount'] as num).toStringAsFixed(2)}', style: TextStyle(color: textColor)),
                          subtitle: Text(tx['description'] ?? '', style: TextStyle(color: textColor.withOpacity(0.7))),
                          trailing: Text(tx['date'] != null ? tx['date'].toString().substring(0, 16).replaceFirst('T', ' ') : '', style: TextStyle(color: textColor.withOpacity(0.6))),
                        );
                      },
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
  List<Category> _categories = [];
  String? _selectedCategoryId;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _listenToCategories();
  }

  void _listenToCategories() {
    _firestore.collection('categories').snapshots().listen((snapshot) {
      final categories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      // Debug print to check Firestore data
      print('Firestore categories snapshot:');
      for (var doc in snapshot.docs) {
        print('  id: \'${doc.id}\', data: \'${doc.data()}\'');
      }
      setState(() => _categories = categories);
      if (_selectedCategoryId == null && categories.isNotEmpty) {
        _selectCategory(categories.first.id);
      }
    });
  }

  void _selectCategory(String categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _firestore.collection('categories').doc(categoryId).collection('tasks').snapshots().listen((snapshot) {
      setState(() {
        _tasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      });
    });
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
                await _firestore.collection('categories').add({'name': name});
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
                await _firestore.collection('categories').doc(category.id).update({'name': name});
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
    await _firestore.collection('categories').doc(category.id).delete();
    if (_selectedCategoryId == category.id) {
      setState(() => _selectedCategoryId = null);
    }
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
