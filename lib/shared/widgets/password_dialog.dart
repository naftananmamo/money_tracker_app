import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import 'custom_button.dart';

class PasswordDialog extends StatelessWidget {
  final UserRole role;
  final VoidCallback onSuccess;

  const PasswordDialog({
    super.key,
    required this.role,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.of(context).pop(); // Close dialog
          onSuccess();
        }
      },
      builder: (context, state) => AlertDialog(
        title: Text('Enter password for ${role.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              enabled: state is! AuthLoading,
            ),
            if (state is AuthFailure)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (state is AuthLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: state is AuthLoading 
                ? null 
                : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Confirm',
            isLoading: state is AuthLoading,
            onPressed: state is AuthLoading
                ? () {}
                : () {
                    context.read<AuthCubit>().authenticate(
                      role,
                      controller.text,
                    );
                  },
          ),
        ],
      ),
    );
  }
}
