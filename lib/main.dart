import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/shared/presentation/pages/main_dashboard.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/admin/presentation/cubits/admin_cubit.dart';
import 'features/admin/presentation/cubits/admin_transaction_cubit.dart';
import 'features/admin/data/firebase_admin_repo.dart';
import 'utils/app_theme.dart';

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
  
  runApp(const AbiyeApp());
}

class AbiyeApp extends StatelessWidget {
  const AbiyeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(FirebaseAuthRepository()),
        ),
        BlocProvider(
          create: (context) => AdminCubit(FirebaseAdminRepo()),
        ),
        BlocProvider(
          create: (context) => AdminTransactionCubit(FirebaseAdminRepo()),
        ),
      ],
      child: MaterialApp(
        title: 'Abiye App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/dashboard': (context) => const MainDashboard(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is AuthSuccess) {
          return const MainDashboard();
        }
        
        // AuthInitial, AuthFailure
        return const LoginPage();
      },
    );
  }
}
