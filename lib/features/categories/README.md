# Categories Feature Implementation Guide

## Overview
This folder contains the structure for implementing the Categories feature following Clean Architecture principles. The categories will allow users to organize their transactions by different spending/earning categories.

## Project Context
- **App**: Family Money Management App
- **Architecture**: Clean Architecture with features-based organization
- **State Management**: Cubit (flutter_bloc)
- **Database**: Firebase Firestore
- **Error Handling**: dartz Either pattern with custom Failure classes

## Existing Dependencies Available
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  dartz: ^0.10.1
  cloud_firestore: ^4.17.5
  get_it: ^7.6.7
```

## Feature Structure
```
lib/features/categories/
├── data/
│   ├── datasources/
│   │   └── category_remote_datasource.dart
│   ├── models/
│   │   └── category_model.dart
│   └── repositories/
│       └── category_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── category.dart
│   ├── repositories/
│   │   └── category_repository.dart
│   └── usecases/
│       └── category_usecases.dart
└── presentation/
    ├── cubit/
    │   └── category_cubit.dart
    └── pages/
        └── categories_page.dart
```

## Implementation Order
1. **Domain Layer** (Business Logic)
   - `category.dart` - Define the Category entity
   - `category_repository.dart` - Define repository interface
   - `category_usecases.dart` - Implement use cases

2. **Data Layer** (External Dependencies)
   - `category_model.dart` - Data model with JSON serialization
   - `category_remote_datasource.dart` - Firestore operations
   - `category_repository_impl.dart` - Repository implementation

3. **Presentation Layer** (UI)
   - `category_cubit.dart` - State management
   - `categories_page.dart` - Main UI page

## Integration Points

### Navigation
The Categories page should be accessible from the drawer in the dashboard:
```dart
// In shared/widgets/app_drawer.dart, update the Categories ListTile:
ListTile(
  title: Text('Categories', style: TextStyle(color: textColor)),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesPage()),
    );
  },
),
```

### Dependency Injection
Add to `injection_container.dart`:
```dart
// Categories
sl.registerLazySingleton(() => CategoryRemoteDataSourceImpl(firestore: sl()));
sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(remoteDataSource: sl()));
sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
// ... other use cases
sl.registerFactory(() => CategoryCubit(getAllCategoriesUseCase: sl(), createCategoryUseCase: sl()));
```

### Shared Widgets Available
- `SectionCard` - For consistent card layouts
- `CustomButton` - For buttons
- `AppDrawer` - Navigation drawer (already includes Categories)

### Theme Integration
Follow the existing theme pattern:
```dart
final bool isAbiye = widget.role == UserRole.abiye;
final Color mainColor = isAbiye ? AppTheme.abiyeColor : AppTheme.tediColor;
final Color textColor = isAbiye ? AppTheme.abiyeTextColor : const Color(0xFF263238);
final Color cardColor = isAbiye ? AppTheme.abiyeCard : Colors.white;
final Color bgColor = isAbiye ? AppTheme.abiyeBg : const Color(0xFFF5F7FA);
```

## Firestore Structure Suggestion
```
categories/ (collection)
├── {categoryId}/ (document)
│   ├── id: string
│   ├── name: string
│   ├── description: string
│   ├── color: string (hex color)
│   ├── iconCodePoint: string
│   ├── createdAt: timestamp
│   └── isActive: boolean
```

## Testing Strategy
- Unit tests for use cases
- Widget tests for UI components
- Integration tests for full feature flow

## UI Requirements
- **List View**: Display all categories with icons and colors
- **Add Category**: Modal/dialog for creating new categories
- **Edit Category**: Ability to modify existing categories
- **Delete Category**: With confirmation dialog
- **Search**: Filter categories by name
- **Color Picker**: For category colors
- **Icon Picker**: For category icons

## Notes
- Follow the existing code patterns from auth and family features
- Use the same error handling approach (Failure classes)
- Maintain consistency with the app's theming
- Categories should be shared across all family members
- Consider category usage analytics for future features

## Questions/Issues
Please reach out if you need clarification on:
- Existing codebase patterns
- Integration with family/transaction features
- UI/UX requirements
- Firebase security rules
