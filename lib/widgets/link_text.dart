import 'package:flutter/material.dart';

/// Un enlace de texto clickable, sin padding extra,
/// que hereda el estilo de texto del tema o usa uno personalizado.
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
    final defaultStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.secondary,
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
    );

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Text(text, style: defaultStyle),
    );
  }
}
