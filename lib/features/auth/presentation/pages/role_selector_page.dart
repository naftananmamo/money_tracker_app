import 'package:flutter/material.dart';
import '../../domain/entities/user_role.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/password_dialog.dart';
import '../../../../utils/app_theme.dart';
import '../../../family/presentation/pages/dashboard_page.dart';

class RoleSelectorPage extends StatelessWidget {
  const RoleSelectorPage({super.key});

  void _showPasswordDialog(BuildContext context, UserRole role) async {
    await showDialog(
      context: context,
      builder: (ctx) => PasswordDialog(
        role: role,
        onSuccess: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(role: role),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const IconData fatherIcon = Icons.family_restroom;
    const IconData daughterIcon = Icons.group;
    
    return Scaffold(
      backgroundColor: AppTheme.landingBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Your Role', 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.bold, 
                color: AppTheme.abiyeColor
              )
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Tedi',
              icon: fatherIcon,
              backgroundColor: AppTheme.tediColor,
              onPressed: () => _showPasswordDialog(context, UserRole.tedi),
              width: 200,
              height: 56,
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Challengers',
              icon: daughterIcon,
              backgroundColor: AppTheme.abiyeColor,
              onPressed: () {
                // No password required for Challengers
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DashboardPage(role: UserRole.abiye),
                  ),
                );
              },
              width: 200,
              height: 56,
            )
          ],
        ),
      ),
    );
  }
}
