import 'package:flutter/material.dart';
import 'package:track_fit_app/models/message.dart';

class HisMessageBubble extends StatelessWidget {
  final Message message;

  const HisMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth:
                size.width *
                0.65, // El mensaje ocupa hasta el 75% de la pantalla
          ),
          decoration: BoxDecoration(
            color: actualTheme.colorScheme.primaryFixed,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              message.text,
              style: TextStyle(
                color:
                    actualTheme.colorScheme.secondary == Color(0xFFD9B79A)
                        ? actualTheme.colorScheme.onSecondary
                        : actualTheme.colorScheme.secondary,
              ),
            ),
          ),
        ),
        SizedBox(height: 5),
      ],
    );
  }
}
