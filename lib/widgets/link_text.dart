import 'package:flutter/material.dart';

/// Un enlace de texto clickable
class LinkText extends StatelessWidget {
  /// Texto que se muestra.
  final String text;

  /// Acción al pulsar.
  final VoidCallback onTap;

  /// Estilo opcional. Si no se especifica, toma
  /// Theme.of(context).textTheme.bodyMedium con color primary.
  final TextStyle? style;

  /// Si quieres subrayar el texto (por defecto false).
  final bool underline;

  const LinkText({
    super.key,
    required this.text,
    required this.onTap,
    this.style,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    // 1) Calcula el estilo final
    final base =
        style ??
        Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: actualTheme.colorScheme.secondary,
        );
    final textStyle = base.copyWith(
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      color: actualTheme.colorScheme.secondary
    );

    // 2) Amplío un poco el área activa con algo de padding
    return InkWell(
      onTap: () {
        debugPrint('LinkText tapped: $text');
        onTap();
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Text(text, style: textStyle),
      ),
    );
  }
}
