import 'package:flutter/material.dart';

/// Campo de fecha objetivo: muestra un TextFormField con icono de calendario
class FechaObjetivoField extends StatelessWidget {
  // Controlador para el texto que muestra la fecha
  final TextEditingController controller;
  // Indica si el campo es editable (muestra o no el icono)
  final bool isEditable;
  // Callback al pulsar el icono de calendario
  final VoidCallback onTapIcon;
  // Etiqueta del campo
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
      // Fondo y bordes redondeados
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: controller, // Controla el texto mostrado
        readOnly: true, // Siempre lee desde el controlador
        enabled: isEditable, // Activa/desactiva el campo
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label, // Texto de la etiqueta
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.secondary,
          ),
          border: InputBorder.none, // Sin borde nativo
          suffixIcon:
              isEditable // Muestra icono solo si editable
                  ? IconButton(
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: onTapIcon, // Abre el picker al pulsar
                  )
                  : null,
        ),
      ),
    );
  }
}
