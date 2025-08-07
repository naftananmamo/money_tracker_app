import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Features
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/family/data/repositories/family_repository_impl.dart';
import 'features/family/domain/repositories/family_repository.dart';
import 'features/family/presentation/cubit/family_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Cubit
  sl.registerFactory(() => AuthCubit(sl()));
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  //! Features - Family
  // Cubit
  sl.registerFactory(() => FamilyCubit(sl()));
  
  // Repository
  sl.registerLazySingleton<FamilyRepository>(() => FamilyRepositoryImpl(sl()));

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}
