import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/repos/admin_repo.dart';

class FirebaseAdminRepo implements AdminRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache to reduce Firebase reads
  Map<String, bool> _adminCache = {};
  DateTime? _lastCacheUpdate;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  @override
  Future<bool> checkAdminExists(String email) async {
    try {
      // Check cache first
      if (_adminCache.containsKey(email) && _isCacheValid()) {
        return _adminCache[email]!;
      }
      
      final doc = await _firestore.collection('admins').doc(email).get();
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
  Future<bool> createAdmin(String email, String password) async {
    try {
      await _firestore.collection('admins').doc(email).set({
        'email': email,
        'password': password, // In production, this should be hashed
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isAdmin(String email) async {
    return await checkAdminExists(email);
  }

  @override
  Future<bool> loginAdmin(String email, String password) async {
    try {
      // Single read to check both existence and password
      final doc = await _firestore.collection('admins').doc(email).get();
      if (!doc.exists) {
        return false; // Admin doesn't exist in Firebase
      }
      
      final adminData = doc.data()!;
      final isValid = adminData['password'] == password;
      
      // Update cache on successful login
      if (isValid) {
        _adminCache[email] = true;
        _lastCacheUpdate = DateTime.now();
      }
      
      return isValid;
    } catch (e) {
      return false;
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
        
        final currentBalance = (userSnapshot.data()!['balance'] ?? 0.0).toDouble();
        final newBalance = currentBalance + amount;
        
        transaction.update(userDoc, {'balance': newBalance});
        
        // Add transaction record
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'amount': amount,
          'type': 'admin_add',
          'reason': reason,
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
        
        final currentBalance = (userSnapshot.data()!['balance'] ?? 0.0).toDouble();
        final newBalance = currentBalance - amount;
        
        transaction.update(userDoc, {'balance': newBalance});
        
        // Add transaction record
        transaction.set(_firestore.collection('transactions').doc(), {
          'userId': userId,
          'amount': -amount,
          'type': 'admin_remove',
          'reason': reason,
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
}
