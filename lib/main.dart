// ✅ Updated Flutter App Code with organized folder structure
// - Models: FamilyUser, UserTransaction, Category, Task, UserRole
// - Screens: RoleSelector, Dashboard, CategoryManager  
// - Utils: AppTheme for consistent styling
// - Widgets: Custom reusable widgets

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/role_selector_screen.dart';
import 'utils/app_theme.dart';

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

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abiye App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const RoleSelector(),
    );
  }
}