// lib/widgets/app_divider.dart
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  // Grosor de la línea
  final double thickness;
  // Altura total del Divider (incluye espacio vertical)
  final double height;
  // Color opcional; si es null, usa el color secundario del tema con 40% de opacidad
  final Color? color;
  // Margen externo alrededor del Divider
  final EdgeInsetsGeometry margin;

  const CustomDivider({
    super.key,
    this.thickness = 1.0,
    this.height = 1.0,
    this.color,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    // Obtiene el tema actual para colores por defecto
    final actualTheme = Theme.of(context);
    return Container(
      margin: margin,
      child: Divider(
        thickness: thickness,
        height: height,
        // Usa el color personalizado o el color secundario del tema al 40% de opacidad
        color:
            color ??
            actualTheme.colorScheme.secondary.withAlpha((0.4 * 255).round()),
      ),
    );
  }
}
