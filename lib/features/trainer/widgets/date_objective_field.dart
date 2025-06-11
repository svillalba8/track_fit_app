import 'package:flutter/material.dart';

class FechaObjetivoField extends StatelessWidget {
  final TextEditingController controller;
  final bool isEditable;
  final VoidCallback onTapIcon;
  final String label;

  const FechaObjetivoField({
    super.key,
    required this.controller,
    required this.isEditable,
    required this.onTapIcon,
    this.label = 'Fecha objetivo',
  });

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
        readOnly: true,
        enabled: isEditable,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          border: InputBorder.none,
          suffixIcon:
              isEditable
                  ? IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: onTapIcon,
                  )
                  : null,
        ),
      ),
    );
  }
}
