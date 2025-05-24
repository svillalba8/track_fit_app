// lib/widgets/app_divider.dart
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double thickness;
  final double height;
  final Color? color;
  final EdgeInsetsGeometry margin;

  const CustomDivider({
    super.key,
    this.thickness = 1.0,
    this.height = 1.0,
    this.color,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: margin,
      child: Divider(
        thickness: thickness,
        height: height,
        color:
            color ?? theme.colorScheme.secondary.withAlpha((0.4 * 255).round()),
      ),
    );
  }
}
