import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../utils/app_theme.dart';
import 'dashboard_screen.dart';

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key});

  void _showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Enter password for Tedi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text == 'Tediab1234') {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard(role: UserRole.tedi)));
                } else {
                  setState(() => error = 'Incorrect password');
                }
              },
              child: const Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const IconData fatherIcon = Icons.family_restroom;
    const IconData daughterIcon = Icons.face_4;
    
    return Scaffold(
      backgroundColor: AppTheme.landingBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Who are you?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.abiyeColor)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(fatherIcon, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.tediColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _showPasswordDialog(context),
              label: const Text('Tedi', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(daughterIcon, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.abiyeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Dashboard(role: UserRole.abiye))),
              label: const Text('Abiye ', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
