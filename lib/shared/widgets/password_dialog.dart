import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_role.dart';

class PasswordDialog extends StatefulWidget {
  final UserRole role;
  final VoidCallback onSuccess;

  const PasswordDialog({
    super.key,
    required this.role,
    required this.onSuccess,
  });

  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword() async {
    setState(() {
      _isLoading = true;
    });

    final authCubit = context.read<AuthCubit>();
    final isValid = await authCubit.validateRolePassword(
      widget.role,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (isValid) {
      Navigator.of(context).pop();
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter ${widget.role.displayName} Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
            onSubmitted: (_) => _validatePassword(),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _validatePassword,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
