/// Category State Management
/// TODO: Implement CategoryCubit and CategoryState
/// 
/// State classes needed:
/// - CategoryInitial
/// - CategoryLoading  
/// - CategoryLoaded
/// - CategoryError
/// - CategoryOperationSuccess
/// 
/// Example:
/// ```dart
/// // States
/// abstract class CategoryState extends Equatable {
///   const CategoryState();
///   
///   @override
///   List<Object> get props => [];
/// }
/// 
/// class CategoryInitial extends CategoryState {}
/// 
/// class CategoryLoading extends CategoryState {}
/// 
/// class CategoryLoaded extends CategoryState {
///   final List<Category> categories;
///   
///   const CategoryLoaded(this.categories);
///   
///   @override
///   List<Object> get props => [categories];
/// }
/// 
/// class CategoryError extends CategoryState {
///   final String message;
///   
///   const CategoryError(this.message);
///   
///   @override
///   List<Object> get props => [message];
/// }
/// 
/// // Cubit
/// class CategoryCubit extends Cubit<CategoryState> {
///   final GetAllCategoriesUseCase getAllCategoriesUseCase;
///   final CreateCategoryUseCase createCategoryUseCase;
///   // ... other use cases
///   
///   CategoryCubit({
///     required this.getAllCategoriesUseCase,
///     required this.createCategoryUseCase,
///     // ... other use cases
///   }) : super(CategoryInitial());
///   
///   Future<void> loadCategories() async {
///     emit(CategoryLoading());
///     final result = await getAllCategoriesUseCase();
///     result.fold(
///       (failure) => emit(CategoryError(failure.message)),
///       (categories) => emit(CategoryLoaded(categories)),
///     );
///   }
///   
///   // ... other methods
/// }
/// ```

// TODO: Implement CategoryCubit and CategoryState here
