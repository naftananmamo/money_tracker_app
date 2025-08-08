import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/presentation/pages/login_page.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  bool _showAllUsersBalances = false;
  String _userName = '';
  DateTime? _lastUserLoad; // Cache timestamp for users

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTransactions();
    _loadAllUsers();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
      });
    }
  }

  Future<void> _loadAllUsers() async {
    try {
      // Only load if we don't have users cached or it's been too long
      if (_allUsers.isNotEmpty && 
          _lastUserLoad != null && 
          DateTime.now().difference(_lastUserLoad!) < const Duration(minutes: 2)) {
        return; // Use cached data
      }
      
      final querySnapshot = await _firestore.collection('users').limit(20).get(); // Limit users
      final users = <Map<String, dynamic>>[];
      
      for (var doc in querySnapshot.docs) {
        final userData = doc.data();
        userData['id'] = doc.id;
        
        // Calculate user's balance from transactions
        final userTransactions = _transactions.where((t) => t['userId'] == doc.id).toList();
        double balance = 0.0;
        for (var transaction in userTransactions) {
          final amount = transaction['amount']?.toDouble() ?? 0.0;
          final type = transaction['type'] ?? 'expense';
          if (type == 'income') {
            balance += amount;
          } else {
            balance -= amount;
          }
        }
        userData['calculatedBalance'] = balance;
        users.add(userData);
      }
      
      if (mounted) {
        setState(() {
          _allUsers = users;
          _lastUserLoad = DateTime.now(); // Update cache timestamp
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTransactions() async {
    try {
      // Load all transactions to show shared transaction history
      final querySnapshot = await _firestore
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .limit(20) // Reduced limit to save quota
          .get();
      
      if (mounted) {
        final transactions = <Map<String, dynamic>>[];
        
        // Get all unique user IDs first
        final userIds = querySnapshot.docs
            .map((doc) => doc.data()['userId'])
            .where((id) => id != null)
            .toSet();
        
        // Batch fetch all user details at once
        final userCache = <String, Map<String, dynamic>>{};
        for (String userId in userIds) {
          try {
            final userSnapshot = await _firestore.collection('users').doc(userId).get();
            if (userSnapshot.exists) {
              userCache[userId] = userSnapshot.data() ?? {};
            }
          } catch (e) {
            // Continue even if one user fetch fails
          }
        }
        
        // Now process transactions with cached user data
        for (var doc in querySnapshot.docs) {
          final transaction = {
            'id': doc.id,
            ...doc.data(),
          };
          
          // Get user details from cache
          final userId = transaction['userId'];
          if (userId != null && userCache.containsKey(userId)) {
            final userData = userCache[userId]!;
            transaction['userName'] = userData['name'] ?? userData['displayName'] ?? 'Unknown User';
            transaction['userEmail'] = userData['email'] ?? 'Unknown Email';
          } else if (userId != null) {
            transaction['userName'] = 'Unknown User';
            transaction['userEmail'] = 'Unknown Email';
          } else {
            transaction['userName'] = 'System';
            transaction['userEmail'] = 'system@abiye.com';
          }
          
          transactions.add(transaction);
        }
        
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abiye App'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTransactions,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $_userName!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Here\'s your financial overview',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildBalanceCard('Balance', _calculateBalance(), Colors.green),
                        const SizedBox(width: 16),
                        _buildBalanceCard('My Transactions', _getCurrentUserTransactionCount(), Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      'Reports',
                      Icons.analytics,
                      Colors.blue,
                      () => _showReportsDialog(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // All Users Balances Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Header with toggle button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showAllUsersBalances = !_showAllUsersBalances;
                        });
                      },
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.purple.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Challengers Balance',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _showAllUsersBalances ? 0.5 : 0,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expandable content
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showAllUsersBalances ? null : 0,
                      child: _showAllUsersBalances ? _buildUsersBalancesList() : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Transaction History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Transactions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _loadTransactions(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Transactions List
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_transactions.isEmpty)
                _buildEmptyState()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionCard(transaction);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final amount = transaction['amount']?.toDouble() ?? 0.0;
    final description = transaction['description'] ?? 'No description';
    final category = transaction['category'] ?? 'General';
    final type = transaction['type'] ?? 'expense';
    final timestamp = transaction['timestamp'] as Timestamp?;
    final userName = transaction['userName'] ?? 'Unknown User';
    final userId = transaction['userId'];
    final currentUser = _auth.currentUser;
    
    final isIncome = type == 'income';
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    
    // Check if this transaction belongs to the current user
    final isCurrentUser = currentUser != null && userId == currentUser.uid;
    final userDisplayName = isCurrentUser ? 'You' : userName;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isCurrentUser ? 3 : 1, // Highlight current user's transactions
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isCurrentUser 
            ? Border.all(color: Colors.blue.shade300, width: 1)
            : null,
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: color,
            ),
          ),
          title: Text(
            description,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(category),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isCurrentUser ? Icons.person : Icons.person_outline,
                    size: 14,
                    color: isCurrentUser ? Colors.blue : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.blue : Colors.grey[600],
                      fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (timestamp != null)
                Text(
                  _formatDate(timestamp.toDate()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions from all users will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateBalance() {
    double balance = 0.0;
    final currentUser = _auth.currentUser;
    
    // Only calculate balance for current user's transactions
    for (var transaction in _transactions) {
      final userId = transaction['userId'];
      if (currentUser != null && userId == currentUser.uid) {
        final amount = transaction['amount']?.toDouble() ?? 0.0;
        final type = transaction['type'] ?? 'expense';
        if (type == 'income') {
          balance += amount;
        } else {
          balance -= amount;
        }
      }
    }
    return '\$${balance.toStringAsFixed(2)}';
  }

  String _getCurrentUserTransactionCount() {
    final currentUser = _auth.currentUser;
    int count = 0;
    
    // Count only current user's transactions
    for (var transaction in _transactions) {
      final userId = transaction['userId'];
      if (currentUser != null && userId == currentUser.uid) {
        count++;
      }
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reports'),
        content: const Text('Reports feature will be implemented soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersBalancesList() {
    if (_allUsers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Loading users...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...(_allUsers.map((userData) {
            final userId = userData['id'] ?? '';
            final userName = userData['name'] ?? 'Unknown User';
            final balance = userData['balance'] ?? 0.0;
            final transactionCount = userData['transactionCount'] ?? 0;
            final isCurrentUser = _auth.currentUser?.uid == userId;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: isCurrentUser
                    ? LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isCurrentUser ? null : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrentUser ? Colors.blue.shade300 : Colors.grey.shade200,
                  width: isCurrentUser ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCurrentUser ? Colors.blue.shade400 : Colors.purple.shade400,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        isCurrentUser ? Icons.person : Icons.person_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrentUser ? Colors.blue.shade700 : Colors.grey.shade800,
                                ),
                              ),
                              if (isCurrentUser) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'You',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '$transactionCount transactions',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                        ),
                        Text(
                          'Balance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
