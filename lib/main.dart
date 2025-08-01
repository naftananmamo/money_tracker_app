import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/pages/role_selector_page.dart';
import 'utils/app_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MoneyTrackerApp());
}

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<AuthCubit>(),
      child: MaterialApp(
        title: 'Abiye App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const RoleSelectorPage(),
      ),
    );
  }
}