import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ObjetivoPesoWidget extends StatelessWidget {
  final double? pesoUsuario;
  final double? pesoObjetivo;
  final DateTime? fechaObjetivo;

  const ObjetivoPesoWidget({
    super.key,
    this.pesoUsuario,
    this.pesoObjetivo,
    this.fechaObjetivo,
  });

  @override
  Widget build(BuildContext context) {
    final fechaFormateada =
        fechaObjetivo != null
            ? DateFormat('dd/MM/yyyy').format(fechaObjetivo!)
            : 'No establecida';

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

  Widget _buildFila(String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Color(0x993C3C43)),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1C1E),
          ),
        ),
      ],
    );
  }
}
