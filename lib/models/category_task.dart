class Category {
  final String id;
  final String name;
  
  Category({required this.id, required this.name});

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

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'createdAt': createdAt.toIso8601String(),
      };
}
