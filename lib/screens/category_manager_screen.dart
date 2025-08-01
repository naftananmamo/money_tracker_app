import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../models/category_task.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_widgets.dart';

class CategoryManager extends StatefulWidget {
  final UserRole role;
  const CategoryManager({super.key, required this.role});

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
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
                setState(() {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    price: price,
                    createdAt: DateTime.now(),
                  );
                  _tasksByCategory[_selectedCategoryId!]?.add(newTask);
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
                setState(() {
                  final tasks = _tasksByCategory[_selectedCategoryId!];
                  if (tasks != null) {
                    final index = tasks.indexWhere((t) => t.id == task.id);
                    if (index != -1) {
                      tasks[index] = Task(
                        id: task.id,
                        name: name,
                        price: price,
                        createdAt: task.createdAt,
                      );
                    }
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

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _tasksByCategory[_selectedCategoryId!]?.removeWhere((t) => t.id == task.id);
    });
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
        : AppTheme.abiyeAccent; // Vibrant pink for Abiye
    final Color secondaryColor = isTedi
        ? AppTheme.tediColor // Slightly darker for Tedi
        : AppTheme.abiyeColor; // Hot pink accent for Abiye
    final Color gradientStart = isTedi
        ? const Color(0xFFE3F2FD) // Soft blue for Tedi
        : AppTheme.abiyeBg; // Vibrant pink bg for Abiye
    final Color gradientEnd = isTedi
        ? const Color(0xFF90CAF9) // Soft blue for Tedi
        : AppTheme.abiyeCard; // Vibrant pink for Abiye
    final Color cardColor = isTedi
        ? Colors.white
        : AppTheme.abiyeCard; // Vibrant pink card for Abiye
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
            CategoryManagerHoverArrow(mainColor: mainColor),
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
