import 'package:flutter/material.dart';
import 'package:track_fit_app/models/message.dart';

/// Burbuja de mensaje enviada por el usuario (alineada a la derecha)
class MyMessageBubble extends StatelessWidget {
  // Mensaje a mostrar
  final Message message;

  const MyMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end, // Alinea a la derecha
      children: [
        Container(
          // Limita ancho al 65% del ancho de pantalla
          constraints: BoxConstraints(maxWidth: size.width * 0.65),
          decoration: BoxDecoration(
            color: actualTheme.colorScheme.onTertiary, // Fondo de la burbuja
            borderRadius: BorderRadius.circular(20), // Bordes redondeados
          ),
          child: Padding(
            // Relleno interno
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              message.text, // Texto del mensaje
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
        const SizedBox(height: 5), // Espacio entre burbujas
      ],
    );
  }
}
