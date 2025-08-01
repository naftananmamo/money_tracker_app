import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/category.dart';

/// Category Repository Interface
/// TODO: Define the contract for category operations
/// 
/// This should include methods for:
/// - Creating new categories
/// - Reading/fetching categories
/// - Updating existing categories
/// - Deleting categories
/// - Searching categories
/// 
/// Example:
/// ```dart
/// abstract class CategoryRepository {
///   Future<Either<Failure, List<Category>>> getAllCategories();
///   Future<Either<Failure, Category>> getCategoryById(String id);
///   Future<Either<Failure, void>> createCategory(Category category);
///   Future<Either<Failure, void>> updateCategory(Category category);
///   Future<Either<Failure, void>> deleteCategory(String id);
///   Future<Either<Failure, List<Category>>> searchCategories(String query);
/// }
/// ```

// TODO: Implement CategoryRepository interface here
