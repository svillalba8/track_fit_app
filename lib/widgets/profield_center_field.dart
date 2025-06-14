import 'package:flutter/material.dart';

class ProfileCenterField extends StatelessWidget {
  // Controlador del campo de texto
  final TextEditingController controller;
  // Texto de la etiqueta que aparece arriba del campo
  final String label;
  // Tipo de teclado (texto, número, email, etc.)
  final TextInputType keyboardType;
  // Función de validación del campo
  final String? Function(String?)? validator;
  // Número máximo de líneas del campo
  final int maxLines;
  // Solo lectura si es true
  final bool? readOnly;

  const ProfileCenterField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    return Container(
      // Espaciado interno y estilo del contenedor
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Etiqueta centrada arriba del campo
          Text(
            label,
            textAlign: TextAlign.center,
            style: actualTheme.textTheme.bodyMedium?.copyWith(
              color: actualTheme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 2),

          // Campo de texto centralizado
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly ?? false,
            textAlign: TextAlign.center,
            style: actualTheme.textTheme.headlineSmall?.copyWith(
              color: actualTheme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
            cursorColor: actualTheme.colorScheme.secondary,
            validator: validator,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
