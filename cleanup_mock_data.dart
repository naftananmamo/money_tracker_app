import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  print('Starting cleanup of mock data...');
  
  try {
    // Get all transactions
    final transactionsSnapshot = await firestore.collection('transactions').get();
    
    print('Found ${transactionsSnapshot.docs.length} transactions');
    
    // Delete transactions that look like mock data
    int deletedCount = 0;
    for (var doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final description = data['description'] ?? '';
      
      // Check if it's mock data
      final mockDescriptions = [
        'Coffee Shop',
        'Salary Deposit', 
        'Grocery Shopping',
        'Sample Transaction',
        'Test Transaction',
      ];
      
      if (mockDescriptions.any((mock) => description.contains(mock))) {
        await doc.reference.delete();
        deletedCount++;
        print('Deleted mock transaction: $description');
      }
    }
    
    print('Cleanup complete! Deleted $deletedCount mock transactions.');
    
    // Also clean up any test users if they exist
    final usersSnapshot = await firestore.collection('users').get();
    print('Found ${usersSnapshot.docs.length} users');
    
    int deletedUsers = 0;
    for (var doc in usersSnapshot.docs) {
      final data = doc.data();
      final email = data['email'] ?? '';
      final name = data['name'] ?? data['displayName'] ?? '';
      
      // Check if it's test data
      final testEmails = [
        'user1@example.com',
        'user2@example.com',
        'user3@example.com',
        'john.doe@example.com',
        'jane.smith@example.com',
        'bob.johnson@example.com',
        'alice.wilson@example.com',
        'test@example.com',
      ];
      
      final testNames = [
        'John Doe',
        'Jane Smith',
        'Bob Johnson',
        'Alice Wilson',
        'Test User',
      ];
      
      if (testEmails.contains(email) || testNames.contains(name)) {
        await doc.reference.delete();
        deletedUsers++;
        print('Deleted test user: $name ($email)');
      }
    }
    
    print('User cleanup complete! Deleted $deletedUsers test users.');
    
  } catch (e) {
    print('Error during cleanup: $e');
  }
}
