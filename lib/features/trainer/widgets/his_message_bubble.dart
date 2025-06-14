import 'package:flutter/material.dart';
import 'package:track_fit_app/models/message.dart';

class HisMessageBubble extends StatelessWidget {
  // Modelo de mensaje proveniente del entrenador
  final Message message;

  const HisMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    // Obtiene tema y tamaño de pantalla
    final actualTheme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Column(
      // Alinea la burbuja a la izquierda
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // Limita el ancho al 65% del ancho de la pantalla
          constraints: BoxConstraints(maxWidth: size.width * 0.65),
          decoration: BoxDecoration(
            color: actualTheme.colorScheme.primaryFixed, // Fondo de la burbuja
            borderRadius: BorderRadius.circular(20), // Bordes redondeados
          ),
          child: Padding(
            // Espaciado interno del texto
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              message.text, // Contenido del mensaje
              style: TextStyle(
                // Ajusta color del texto según tema específico
                color:
                    actualTheme.colorScheme.secondary == const Color(0xFFD9B79A)
                        ? actualTheme.colorScheme.onSecondary
                        : actualTheme.colorScheme.secondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5), // Separador entre burbujas
      ],
    );
  }
}
