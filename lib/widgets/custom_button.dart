import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  // Texto que muestra el botón
  final String text;
  // Callback que se ejecuta al pulsar el botón
  final VoidCallback? onPressed;
  // Tema actual para obtener colores y estilos
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
      // Configuración visual del botón
      style: ElevatedButton.styleFrom(
        elevation: 5,
        backgroundColor: actualTheme.colorScheme.tertiary,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed, // Acción al pulsar
      child: Text(
        text, // Texto del botón
        style: TextStyle(
          color: actualTheme.colorScheme.secondary,
          fontSize: 16,
        ),
      ),
    );
  }
}
