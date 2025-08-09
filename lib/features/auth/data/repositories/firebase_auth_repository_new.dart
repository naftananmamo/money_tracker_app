import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_role.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return Right(credential.user!);
      } else {
        return const Left(AuthFailure('Sign in failed'));
      }
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);
        
        // Create user document in Firestore
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        return Right(credential.user!);
      } else {
        return const Left(AuthFailure('User creation failed'));
      }
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      return Right(_auth.currentUser != null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getCurrentUserEmail() async {
    try {
      return Right(_auth.currentUser?.email);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> authenticateWithPassword({
    required UserRole role,
    required String password,
  }) async {
    try {
      // Get the role password from Firestore or your backend
      final docSnapshot = await _firestore
          .collection('role_passwords')
          .doc(role.name.toLowerCase())
          .get();

      if (docSnapshot.exists) {
        final storedPassword = docSnapshot.data()?['password'] as String?;
        return Right(storedPassword == password);
      } else {
        return const Right(false);
      }
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserRole?>> getCurrentRole() async {
    try {
      // This could be stored in user preferences or Firestore
      // For now, return null (no role set)
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated(UserRole role) async {
    try {
      // Check if user is authenticated for a specific role
      // This could involve checking Firestore for user's roles
      if (_auth.currentUser == null) {
        return const Right(false);
      }

      // For now, assume all authenticated users can access any role
      return const Right(true);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
