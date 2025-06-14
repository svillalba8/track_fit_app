import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  // Icono a mostrar (obligatorio)
  final Widget icon;
  // Texto opcional; si se proporciona, muestra icono+texto
  final String? texto;
  // Tema actual para colores y estilos
  final ThemeData actualTheme;
  // Acción a ejecutar al pulsar
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
    // Botón con icono y texto si 'texto' no es null
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
        onPressed: onPressed, // Callback al pulsar
      );
    }

    // Solo icono: IconButton
    return IconButton(
      padding: EdgeInsets.all(12),
      iconSize: 24,
      icon: icon,
      color: actualTheme.colorScheme.secondary,
      splashRadius: 28,
      onPressed: onPressed, // Callback al pulsar
    );
  }
}
