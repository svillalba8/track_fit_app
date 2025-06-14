import 'package:flutter/material.dart';

// Widget reutilizable que muestra una tarjeta con icono, título, subtítulo y contenido adicional
class HomeCard extends StatelessWidget {
  // Icono a mostrar en la parte superior izquierda de la tarjeta
  final IconData icon;
  // Título principal de la tarjeta
  final String title;
  // Texto opcional debajo del título para descripción breve
  final String? subtitle;
  // Color de fondo de la tarjeta
  final Color backgroundColor;
  // Widget opcional que se muestra en la parte inferior (ej. badge, progreso, lista de datos)
  final Widget? bottomWidget;
  // Callback que se ejecuta al pulsar la tarjeta
  final VoidCallback onTap;

  const HomeCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.backgroundColor = Colors.white,
    this.bottomWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    return GestureDetector(
      // Detecta toque completo de la tarjeta y dispara onTap
      onTap: onTap,
      child: LayoutBuilder(
        // Provee las restricciones de tamaño disponibles para adaptar el contenido
        builder: (context, constraints) {
          return Card(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
            ),
            elevation: 4, // Sombra para dar sensación de profundidad
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                // Permite desplazar verticalmente si el contenido es mayor que el espacio
                child: ConstrainedBox(
                  // Asegura que el contenido mínimo ocupe la altura disponible
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    // Fuerza al Column a tomar la altura mínima necesaria
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              icon,
                              size: 28, // Tamaño del icono
                              color:
                                  actualTheme
                                      .colorScheme
                                      .secondary, // Color temático
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              // Hace que el título ocupe el espacio restante
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1C1C1E),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Si hay subtítulo, lo muestra debajo del título
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0x993C3C43),
                            ),
                          ),
                        ],

                        // Si hay widget inferior, lo inserta con un espacio de separación
                        if (bottomWidget != null) ...[
                          const SizedBox(height: 12),
                          bottomWidget!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
