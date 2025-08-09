import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Initialize Firebase
  await Firebase.initializeApp();
  
  final firestore = FirebaseFirestore.instance;
  
  print('Starting cleanup of ALL mock/sample data...');
  
  try {
    // Get all transactions
    final transactionsSnapshot = await firestore.collection('transactions').get();
    
    print('Found ${transactionsSnapshot.docs.length} transactions');
    
    // Delete ALL transactions that look like mock data
    int deletedCount = 0;
    for (var doc in transactionsSnapshot.docs) {
      final data = doc.data();
      final description = data['description'] ?? '';
      final amount = data['amount']?.toDouble() ?? 0.0;
      
      // Check if it's mock data - expanded list
      final mockDescriptions = [
        'Coffee Shop',
        'Salary Deposit', 
        'Grocery Shopping',
        'Sample Transaction',
        'Test Transaction',
        'Gas Station',
        'Restaurant',
        'Online Purchase',
        'ATM Withdrawal',
        'Bank Transfer',
        'Utility Bill',
        'Rent Payment',
        'Freelance Payment',
        'Investment Return',
        'Gift',
        'Refund',
      ];
      
      // Also check for common mock amounts
      final mockAmounts = [50.0, 100.0, 150.0, 200.0, 250.0, 300.0, 500.0, 1000.0, 2500.0, 3000.0];
      
      bool isMockData = mockDescriptions.any((mock) => description.toLowerCase().contains(mock.toLowerCase())) ||
                       mockAmounts.contains(amount);
      
      if (isMockData) {
        await doc.reference.delete();
        deletedCount++;
        print('Deleted mock transaction: $description (\$${amount.toStringAsFixed(2)})');
      }
    }
    
    print('Transaction cleanup complete! Deleted $deletedCount mock transactions.');
    
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
      
      if (testEmails.contains(email.toLowerCase()) || testNames.contains(name)) {
        await doc.reference.delete();
        deletedUsers++;
        print('Deleted test user: $name ($email)');
      }
    }
    
    print('User cleanup complete! Deleted $deletedUsers test users.');
    print('');
    print('CLEANUP FINISHED! All mock data has been removed.');
    print('You can now test the app - it should show empty states.');
    
  } catch (e) {
    print('Error during cleanup: $e');
  }
}
