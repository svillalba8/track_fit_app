import 'package:flutter/material.dart';

/// Campo de formulario estilizado para editar perfil
class ProfileField extends StatelessWidget {
  // Controlador del texto
  final TextEditingController controller;
  // Etiqueta mostrada arriba del campo
  final String label;
  // Tipo de teclado (texto, número, email…)
  final TextInputType keyboardType;
  // Función de validación opcional
  final String? Function(String?)? validator;
  // Número máximo de líneas
  final int maxLines;
  // Solo lectura si es true
  final bool? readOnly;

  const ProfileField({
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
    final theme = Theme.of(context);

    return Container(
      // Espaciado interno y fondo con bordes redondeados
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary, // Fondo del campo
        borderRadius: BorderRadius.circular(8), // Bordes redondeados
      ),
      child: TextFormField(
        controller: controller, // Controlador del input
        keyboardType: keyboardType, // Teclado según tipo
        maxLines: maxLines, // Líneas permitidas
        readOnly: readOnly ?? false, // Solo lectura opcional
        cursorColor: theme.colorScheme.secondary, // Color del cursor
        decoration: InputDecoration(
          labelText: label, // Texto de la etiqueta
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary, // Color de la etiqueta
          ),
          border: InputBorder.none, // Sin borde nativo
        ),
        validator: validator, // Validación al enviar
      ),
    );
  }
}
