import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        cursorColor: theme.colorScheme.secondary,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.secondary),
          border: InputBorder.none,
        ),
        validator: validator,
      ),
    );
  }
}
