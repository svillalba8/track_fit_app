import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSelector extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
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
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: CupertinoSegmentedControl<String>(
              groupValue: value,
              unselectedColor: theme.colorScheme.primary,
              selectedColor: theme.colorScheme.secondary,
              borderColor: theme.colorScheme.secondary,
              pressedColor: theme.colorScheme.secondary.withAlpha(
                (0.4 * 255).round(),
              ),

              children: {
                for (var item in items)
                  item: Center(
                    child: Text(
                      item.substring(0, 1),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              },

              onValueChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
