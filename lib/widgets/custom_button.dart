import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ThemeData actualTheme;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.actualTheme,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: actualTheme.colorScheme.tertiary,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: actualTheme.colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    );
  }
}
