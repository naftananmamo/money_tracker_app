import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../../utils/app_theme.dart';
import '../../../auth/presentation/pages/role_selector_page.dart';
import '../../../../shared/widgets/user_selection_dialog.dart';
import '../../../../shared/widgets/add_user_dialog.dart';
import '../cubit/family_cubit.dart';
import '../cubit/family_state.dart';
import '../../../../injection_container.dart' as di;

class DashboardPage extends StatelessWidget {
  final UserRole role;
  const DashboardPage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<FamilyCubit>()..loadFamilyData(),
      child: DashboardView(role: role),
    );
  }
}

class DashboardView extends StatefulWidget {
  final UserRole role;
  const DashboardView({super.key, required this.role});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
  }

  void _showMoneyDialog({
    required FamilyUser user,
    required bool isAddition,
  }) {
    showDialog(
      context: context,
      builder: (context) => MoneyDialog(
        user: user,
        isAddition: isAddition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAbiye = widget.role == UserRole.abiye;
    final Color mainColor = isAbiye ? AppTheme.abiyeColor : AppTheme.tediColor;
    final Color accentColor = isAbiye ? AppTheme.abiyeAccent : const Color(0xFF263238);
    final Color bgColor = isAbiye ? AppTheme.abiyeBg : const Color(0xFFF5F7FA);
    final Color cardColor = isAbiye ? AppTheme.abiyeCard : Colors.white;
    final Color textColor = isAbiye ? accentColor : const Color(0xFF263238);
    
    return Scaffold(
      backgroundColor: bgColor,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: bgColor),
              child: Text(
                'Menu', 
                style: TextStyle(
                  color: mainColor, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 20
                )
              ),
            ),
            ListTile(
              title: Text('Categories', style: TextStyle(color: textColor)),
              onTap: () {
                // TODO: Navigate to categories
              },
            ),
            if (!isAbiye)
              ListTile(
                title: Text('Manage Users', style: TextStyle(color: textColor)),
                onTap: () {
                  _showAddUserDialog();
                },
              ),
            ListTile(
              title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const RoleSelectorPage())
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(
          widget.role == UserRole.tedi ? 'Family Manager' : 'Family Money', 
          style: const TextStyle(color: Colors.white)
        ),
        actions: [
          BlocBuilder<FamilyCubit, FamilyState>(
            builder: (context, state) {
              double totalBalance = 0.0;
              if (state is FamilyUsersLoaded) {
                totalBalance = state.users.fold(0.0, (sum, user) => sum + user.balance);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    'Total: \$${totalBalance.toStringAsFixed(2)}', 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    )
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<FamilyCubit, FamilyState>(
        listener: (context, state) {
          if (state is FamilyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FamilyOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is FamilyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          List<FamilyUser> users = [];
          List<UserTransaction> transactions = [];
          
          if (state is FamilyUsersLoaded) {
            users = state.users;
            transactions = state.transactions;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Family Members Section
                Card(
                  color: cardColor,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Family Members', 
                              style: TextStyle(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: mainColor
                              )
                            ),
                            if (!isAbiye)
                              IconButton(
                                icon: Icon(Icons.person_add, color: mainColor),
                                onPressed: _showAddUserDialog,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        users.isEmpty
                            ? Text(
                                'No family members added yet', 
                                style: TextStyle(color: textColor)
                              )
                            : Column(
                                children: users.map((user) => FamilyMemberCard(
                                  user: user,
                                  mainColor: mainColor,
                                  textColor: textColor,
                                  isAbiye: isAbiye,
                                  onAddMoney: () => _showMoneyDialog(user: user, isAddition: true),
                                  onSubtractMoney: () => _showMoneyDialog(user: user, isAddition: false),
                                )).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action Buttons (Tedi only)
                if (!isAbiye && users.isNotEmpty) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[50],
                            foregroundColor: Colors.green[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            // Show user selection for adding money
                            _showUserSelectionDialog(isAddition: true, users: users);
                          },
                          label: const Text('Add Money'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[900],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () {
                            // Show user selection for subtracting money
                            _showUserSelectionDialog(isAddition: false, users: users);
                          },
                          label: const Text('Subtract Money'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Recent Transactions
                Card(
                  color: cardColor,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Transactions', 
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold, 
                            color: mainColor
                          )
                        ),
                        const SizedBox(height: 16),
                        transactions.isEmpty
                            ? Text(
                                'No transactions yet!', 
                                style: TextStyle(color: textColor)
                              )
                            : Column(
                                children: transactions.take(10).map((tx) => TransactionCard(
                                  transaction: tx,
                                  textColor: textColor,
                                )).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUserSelectionDialog({required bool isAddition, required List<FamilyUser> users}) {
    showDialog(
      context: context,
      builder: (context) => UserSelectionDialog(
        isAddition: isAddition,
        users: users,
        onUserSelected: (user) => _showMoneyDialog(user: user, isAddition: isAddition),
      ),
    );
  }
}
