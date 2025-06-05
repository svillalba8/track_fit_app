import 'package:flutter/material.dart';

class SelectableAnimatedContainer extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final Color selectedColor;
  final Color unselectedColor;
  final Color selectedBorderColor;
  final Color unselectedBorderColor;
  final List<BoxShadow>? selectedShadow;

  const SelectableAnimatedContainer({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.selectedColor,
    required this.unselectedColor,
    required this.selectedBorderColor,
    required this.unselectedBorderColor,
    this.selectedShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: borderRadius,
          boxShadow: isSelected ? selectedShadow : null,
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 1.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
