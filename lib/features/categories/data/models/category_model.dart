/// Category Model for Data Layer
/// TODO: Create CategoryModel that extends Category entity
/// 
/// This model should:
/// - Extend the Category entity
/// - Include fromJson() and toJson() methods for Firebase
/// - Include fromMap() and toMap() methods
/// - Handle serialization/deserialization
/// 
/// Example:
/// ```dart
/// class CategoryModel extends Category {
///   const CategoryModel({
///     required super.id,
///     required super.name,
///     required super.description,
///     required super.color,
///     required super.iconCodePoint,
///     required super.createdAt,
///     super.isActive,
///   });
/// 
///   factory CategoryModel.fromJson(Map<String, dynamic> json) {
///     return CategoryModel(
///       id: json['id'],
///       name: json['name'],
///       description: json['description'],
///       color: json['color'],
///       iconCodePoint: json['iconCodePoint'],
///       createdAt: DateTime.parse(json['createdAt']),
///       isActive: json['isActive'] ?? true,
///     );
///   }
/// 
///   Map<String, dynamic> toJson() {
///     return {
///       'id': id,
///       'name': name,
///       'description': description,
///       'color': color,
///       'iconCodePoint': iconCodePoint,
///       'createdAt': createdAt.toIso8601String(),
///       'isActive': isActive,
///     };
///   }
/// }
/// ```

// TODO: Implement CategoryModel here
