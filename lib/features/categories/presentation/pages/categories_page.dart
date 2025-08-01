/// Categories Page
/// TODO: Implement the main categories page
/// 
/// This page should:
/// - Display a list of categories
/// - Allow adding new categories
/// - Allow editing existing categories  
/// - Allow deleting categories
/// - Show category icons and colors
/// - Use the existing SectionCard widget from shared/widgets
/// - Follow the app's theme (light background, white cards, proper text colors)
/// 
/// Integration points:
/// - Use CategoryCubit for state management
/// - Navigate from dashboard drawer when "Categories" is tapped
/// - Use shared widgets: SectionCard, CustomButton
/// - Follow the app's color scheme (mainColor, textColor, etc.)
/// 
/// Example structure:
/// ```dart
/// class CategoriesPage extends StatelessWidget {
///   const CategoriesPage({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     return BlocProvider(
///       create: (context) => di.sl<CategoryCubit>()..loadCategories(),
///       child: const CategoriesView(),
///     );
///   }
/// }
/// 
/// class CategoriesView extends StatelessWidget {
///   const CategoriesView({super.key});
/// 
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: const Text('Categories'),
///         // Use theme colors here
///       ),
///       body: BlocConsumer<CategoryCubit, CategoryState>(
///         listener: (context, state) {
///           // Handle success/error states
///         },
///         builder: (context, state) {
///           // Build UI based on state
///           return SingleChildScrollView(
///             padding: const EdgeInsets.all(16),
///             child: Column(
///               children: [
///                 SectionCard(
///                   title: 'Categories',
///                   cardColor: Colors.white,
///                   mainColor: mainColor, // Get from theme
///                   content: // Category list here,
///                   headerAction: // Add category button,
///                 ),
///               ],
///             ),
///           );
///         },
///       ),
///     );
///   }
/// }
/// ```

// TODO: Implement CategoriesPage here
