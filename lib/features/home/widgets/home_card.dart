import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final Widget? bottomWidget; // Puede ser un badge, una barra de progreso, etc.
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
      onTap: onTap,
      child: Card(
        color: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
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
              const SizedBox(height: 6),
              if (subtitle != null) ...[
                Expanded(
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0x993C3C43),
                    ),
                  ),
                ),
              ],

              if (bottomWidget != null) ...[
                const SizedBox(height: 8),
                bottomWidget!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
