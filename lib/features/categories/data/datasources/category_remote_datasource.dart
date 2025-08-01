/// Category Firestore Data Source
/// TODO: Implement Firebase Firestore operations for categories
/// 
/// This should handle:
/// - CRUD operations with Firestore
/// - Real-time listeners for category changes
/// - Error handling for network issues
/// - Batch operations if needed
/// 
/// Example structure:
/// ```dart
/// abstract class CategoryRemoteDataSource {
///   Future<List<CategoryModel>> getAllCategories();
///   Future<CategoryModel> getCategoryById(String id);
///   Future<void> createCategory(CategoryModel category);
///   Future<void> updateCategory(CategoryModel category);
///   Future<void> deleteCategory(String id);
///   Stream<List<CategoryModel>> getCategoriesStream();
/// }
/// 
/// class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
///   final FirebaseFirestore firestore;
///   
///   CategoryRemoteDataSourceImpl({required this.firestore});
///   
///   @override
///   Future<List<CategoryModel>> getAllCategories() async {
///     // Implementation here
///   }
///   
///   // ... other methods
/// }
/// ```

// TODO: Implement CategoryRemoteDataSource here
