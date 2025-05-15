import 'package:flutter/material.dart';

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required TextEditingController emailController,
    required this.actualTheme,
  }) : _emailController = emailController;

  final TextEditingController _emailController;
  final ThemeData actualTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _emailController,
        decoration: InputDecoration(
          labelText: 'Email',
          floatingLabelStyle: TextStyle(
            color: actualTheme.colorScheme.secondary,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.email),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}