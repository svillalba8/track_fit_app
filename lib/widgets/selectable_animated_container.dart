import 'package:flutter/material.dart';

class SelectableAnimatedContainer extends StatelessWidget {
  // Expresa si el contenedor está seleccionado
  final bool isSelected;
  // Callback que se dispara al tocar el contenedor
  final VoidCallback onTap;
  // Contenido interno del contenedor
  final Widget child;
  // Espaciado interno alrededor del child
  final EdgeInsetsGeometry padding;
  // Radio de los bordes redondeados
  final BorderRadius borderRadius;
  // Color de fondo cuando está seleccionado
  final Color selectedColor;
  // Color de fondo cuando no está seleccionado
  final Color unselectedColor;
  // Color del borde cuando está seleccionado
  final Color selectedBorderColor;
  // Color del borde cuando no está seleccionado
  final Color unselectedBorderColor;
  // Sombra opcional que se aplica solo cuando está seleccionado
  final List<BoxShadow>? selectedShadow;

  const SelectableAnimatedContainer({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    // Detecta el toque y ejecuta onTap
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // Anima cualquier cambio en decoración o padding
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding,
        decoration: BoxDecoration(
          // Alterna color de fondo según isSelected
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: borderRadius,
          // Aplica sombra solo si está seleccionado
          boxShadow: isSelected ? selectedShadow : null,
          // Alterna color de borde según isSelected
          border: Border.all(
            color: isSelected ? selectedBorderColor : unselectedBorderColor,
            width: 1.5,
          ),
        ),
        child: child, // Muestra el widget hijo
      ),
    );
  }
}
