import 'package:flutter/material.dart';

/// Widget para seleccionar una opción de una lista con botones arriba/abajo
class OptionStepper extends StatefulWidget {
  // Etiqueta descriptiva que aparece encima
  final String label;
  // Lista de opciones posibles
  final List<String> options;
  // Índice inicial dentro de las opciones (se clampa al rango válido)
  final int initialIndex;
  // Callback con la opción seleccionada al cambiar
  final ValueChanged<String>? onChanged;
  // Iconos para los botones de incrementar/decrementar
  final IconData upIcon;
  final IconData downIcon;

  const OptionStepper({
    super.key,
    required this.label,
    required this.options,
    this.initialIndex = 2,
    this.onChanged,
    this.upIcon = Icons.keyboard_arrow_up,
    this.downIcon = Icons.keyboard_arrow_down,
  });

  @override
  State<OptionStepper> createState() => _OptionStepperState();
}

class _OptionStepperState extends State<OptionStepper> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    // Ajusta el índice inicial dentro del rango de opciones
    currentIndex = widget.initialIndex.clamp(0, widget.options.length - 1);
  }

  /// Incrementa el índice si no está al final y notifica cambio
  void _increment() {
    setState(() {
      if (currentIndex < widget.options.length - 1) {
        currentIndex++;
        widget.onChanged?.call(widget.options[currentIndex]);
      }
    });
  }

  /// Decrementa el índice si no está al inicio y notifica cambio
  void _decrement() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        widget.onChanged?.call(widget.options[currentIndex]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Muestra la etiqueta en negrita
        Text(
          '- ${widget.label}',
          style: actualTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),

        // Contenedor con borde para mostrar la opción y los botones
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Texto de la opción actual, centrado
              Expanded(
                child: Text(
                  widget.options[currentIndex],
                  textAlign: TextAlign.center,
                  style: actualTheme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 16),

              // Columna con botones de incrementar y decrementar
              Column(
                children: [
                  // Botón de subir (incrementar)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: actualTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.upIcon,
                        size: 22,
                        color: actualTheme.colorScheme.primary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                      onPressed: _increment,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Botón de bajar (decrementar)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: actualTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.downIcon,
                        size: 22,
                        color: actualTheme.colorScheme.primary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                      onPressed: _decrement,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
