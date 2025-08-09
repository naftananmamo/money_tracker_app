import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repos/admin_repo.dart';

class FirebaseAdminRepo implements AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Cache to reduce Firebase reads
  final Map<String, bool> _adminCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  Future<bool> checkAdminExists(String email) async {
    try {
      // Check cache first
      if (_adminCache.containsKey(email) && _isCacheValid()) {
        return _adminCache[email]!;
      }
      
      final doc = await _firestore.collection('admin').doc(email).get();
      final exists = doc.exists;
      
      // Update cache
      _adminCache[email] = exists;
      _lastCacheUpdate = DateTime.now();
      
      return exists;
    } catch (e) {
      return false;
    }
  }

  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!) < _cacheTimeout;
  }

  @override
  Future<bool> isAdmin(String email) async {
    return await checkAdminExists(email);
  }

  @override
  Future<bool> loginAdmin(String email, String password) async {
    try {
      // First authenticate with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // If auth successful, check if user is admin in Firestore
      if (userCredential.user != null) {
        final doc = await _firestore.collection('admin').doc(email).get();
        final isAdmin = doc.exists;
        
        // Update cache on successful admin login
        if (isAdmin) {
          _adminCache[email] = true;
          _lastCacheUpdate = DateTime.now();
        }
        
        return isAdmin;
      }
      
      return false;
    } catch (e) {
      // Re-throw the error so the cubit can handle it with specific messages
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      // Limit to recent transactions to reduce quota usage
      final querySnapshot = await _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(50) // Limit to 50 most recent transactions
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> logAdminAction(String action, String targetUser, Map<String, dynamic> details) async {
    try {
      await _firestore.collection('admin_actions').add({
        'action': action,
        'targetUser': targetUser,
        'details': details,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> resetUserPassword(String userId, String newPassword) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'password': newPassword,
        'lastPasswordReset': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      // Limit user transactions to reduce quota usage
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20) // Limit to 20 most recent user transactions
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> addMoneyToUser(String userId, double amount, String reason, String adminEmail) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        if (!userSnapshot.exists) return;
        
        final userData = userSnapshot.data()!;
        final currentBalance = (userData['balance'] ?? 0.0).toDouble();
        final newBalance = currentBalance + amount;
        
        transaction.update(userDoc, {'balance': newBalance});
        
        // Add transaction record
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'userName': userData['name'] ?? userData['displayName'] ?? 'Unknown',
          'userEmail': userData['email'] ?? 'Unknown',
          'amount': amount,
          'type': 'income',
          'description': reason,
          'category': 'Admin Action',
          'adminAction': true,
          'adminEmail': adminEmail,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': newBalance,
        });
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> removeMoneyFromUser(String userId, double amount, String reason, String adminEmail) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);
      
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        if (!userSnapshot.exists) return;
        
        final userData = userSnapshot.data()!;
        final currentBalance = (userData['balance'] ?? 0.0).toDouble();
        final newBalance = currentBalance - amount;
        
        transaction.update(userDoc, {'balance': newBalance});
        
        // Add transaction record
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'userName': userData['name'] ?? userData['displayName'] ?? 'Unknown',
          'userEmail': userData['email'] ?? 'Unknown',
          'amount': amount,
          'type': 'expense',
          'description': reason,
          'category': 'Admin Action',
          'adminAction': true,
          'adminEmail': adminEmail,
          'timestamp': FieldValue.serverTimestamp(),
          'balanceAfter': newBalance,
        });
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
