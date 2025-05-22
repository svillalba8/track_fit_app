import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final String? texto;
  final ThemeData actualTheme;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.texto,
    required this.actualTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Si hay texto, usamos ElevatedButton.icon para icono + texto
    if (texto != null) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: actualTheme.colorScheme.tertiary,
          padding: EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: icon,
        label: Text(
          texto!,
          style: TextStyle(
            color: actualTheme.colorScheme.secondary,
            fontSize: 16,
          ),
        ),
        onPressed: onPressed,
      );
    }

    // Solo icono: IconButton
    return IconButton(
      padding: EdgeInsets.all(12),
      iconSize: 24,
      icon: icon,
      color: actualTheme.colorScheme.secondary,
      splashRadius: 28,
      onPressed: onPressed,
    );
  }
}
