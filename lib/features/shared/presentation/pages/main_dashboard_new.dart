import 'package:flutter/material.dart';
import 'user_dashboard.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new user dashboard with full functionality
    return const UserDashboard();
  }
}
