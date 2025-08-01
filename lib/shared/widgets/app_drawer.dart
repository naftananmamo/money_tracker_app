import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_role.dart';

class AppDrawer extends StatelessWidget {
  final UserRole role;
  final Color bgColor;
  final Color mainColor;
  final Color textColor;
  final VoidCallback? onManageUsers;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.role,
    required this.bgColor,
    required this.mainColor,
    required this.textColor,
    this.onManageUsers,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAbiye = role == UserRole.abiye;
    
    return Drawer(
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
          if (!isAbiye && onManageUsers != null)
            ListTile(
              title: Text('Manage Users', style: TextStyle(color: textColor)),
              onTap: onManageUsers,
            ),
          ListTile(
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: onLogout,
          )
        ],
      ),
    );
  }
}
