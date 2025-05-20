import 'package:flutter/material.dart';

class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required TextEditingController passController,
    required this.message,
    required this.actualTheme,
    required this.onToggleObscure,
    required bool obscureRepeat,
  }) : _passController = passController,
      _obscureRepeat = obscureRepeat;

  final TextEditingController _passController;
  final String message;
  final ThemeData actualTheme;
  final VoidCallback onToggleObscure;
  final bool _obscureRepeat;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _passController,
        decoration: InputDecoration(
          labelText: message,
          floatingLabelStyle: TextStyle(
            color: actualTheme.colorScheme.secondary,
          ),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureRepeat ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onToggleObscure,
          ),
        ),
        obscureText: _obscureRepeat,
      ),
    );
  }
}
