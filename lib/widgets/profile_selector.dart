import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSelector extends StatelessWidget {
  // Etiqueta que describe el selector
  final String label;
  // Valor actualmente seleccionado
  final String value;
  // Opciones disponibles
  final List<String> items;
  // Callback cuando cambia la selección
  final ValueChanged<String> onChanged;

  const ProfileSelector({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    return Container(
      // Espaciado interno y fondo
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: actualTheme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Texto de la etiqueta centrado
          Text(
            label,
            textAlign: TextAlign.center,
            style: actualTheme.textTheme.bodyMedium?.copyWith(
              color: actualTheme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          // Selector
          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl<String>(
              groupValue: value,
              unselectedColor: actualTheme.colorScheme.primary,
              selectedColor: actualTheme.colorScheme.secondary,
              borderColor: actualTheme.colorScheme.secondary,
              pressedColor: actualTheme.colorScheme.secondary.withAlpha(
                (0.4 * 255).round(),
              ),

              // Mapea cada ítem a un widget con su primera letra
              children: {
                for (var item in items)
                  item: Center(
                    child: Text(
                      item.substring(0, 1),
                      textAlign: TextAlign.center,
                      style: actualTheme.textTheme.headlineSmall?.copyWith(
                        color: actualTheme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              },

              // Llama al callback al cambiar selección
              onValueChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
