import 'package:equatable/equatable.dart';

/// Category entity for organizing transactions
/// TODO: Define the Category entity with required properties
/// 
/// Suggested properties:
/// - String id
/// - String name
/// - String description
/// - String color (hex color code)
/// - IconData icon
/// - DateTime createdAt
/// - bool isActive
/// 
/// Example:
/// ```dart
/// class Category extends Equatable {
///   final String id;
///   final String name;
///   final String description;
///   final String color;
///   final String iconCodePoint;
///   final DateTime createdAt;
///   final bool isActive;
/// 
///   const Category({
///     required this.id,
///     required this.name,
///     required this.description,
///     required this.color,
///     required this.iconCodePoint,
///     required this.createdAt,
///     this.isActive = true,
///   });
/// 
///   @override
///   List<Object?> get props => [id, name, description, color, iconCodePoint, createdAt, isActive];
/// }
/// ```

// TODO: Implement Category entity here
