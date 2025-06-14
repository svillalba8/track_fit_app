import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget que muestra el peso actual, el objetivo de peso y la fecha límite
class ObjetivoPesoWidget extends StatelessWidget {
  // Peso actual del usuario en kg
  final double? pesoUsuario;
  // Peso objetivo establecido por el usuario en kg
  final double? pesoObjetivo;
  // Fecha límite para alcanzar el peso objetivo
  final DateTime? fechaObjetivo;

  const ObjetivoPesoWidget({
    super.key,
    this.pesoUsuario,
    this.pesoObjetivo,
    this.fechaObjetivo,
  });

  @override
  Widget build(BuildContext context) {
    // Formatea la fecha a dd/MM/yyyy o indica si no está establecida
    final fechaFormateada =
        fechaObjetivo != null
            ? DateFormat('dd/MM/yyyy').format(fechaObjetivo!)
            : 'No establecida';

    // Construye una columna con tres filas: peso actual, peso objetivo y fecha límite
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFila(
          'Tu peso:',
          pesoUsuario != null ? '${pesoUsuario!} kg' : 'No establecido',
        ),
        const SizedBox(height: 8),
        _buildFila(
          'Peso objetivo:',
          pesoObjetivo != null ? '${pesoObjetivo!} kg' : 'No establecido',
        ),
        const SizedBox(height: 8),
        _buildFila('Fecha objetivo:', fechaFormateada),
      ],
    );
  }

  // Método auxiliar para construir una fila con etiqueta y valor
  Widget _buildFila(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0x993C3C43), // Color gris para etiqueta secundaria
          ),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700, // Negrita para destacar el valor
            color: Color(0xFF1C1C1E), // Color oscuro para el valor principal
          ),
        ),
      ],
    );
  }
}
