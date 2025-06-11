// widget RutinasDialog.dart
import 'package:flutter/material.dart';

import '../../../widgets/custom_button.dart';
import '../../routines/models/routine_model.dart';

class RutinasDialog extends StatelessWidget {
  final List<Routine> todasLasRutinas;
  final VoidCallback onEntrenar;

  const RutinasDialog({
    super.key,
    required this.todasLasRutinas,
    required this.onEntrenar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tus Rutinas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: todasLasRutinas.length,
                itemBuilder: (context, index) {
                  final rutina = todasLasRutinas[index];
                  return ListTile(
                    leading: const Icon(Icons.fitness_center, color: Colors.black54),
                    title: Text(
                      rutina.nombre,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Volver',
                    style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
                CustomButton(
                  text: '¡Vamos a entrenar!',
                  actualTheme: theme,
                  onPressed: () {
                    Navigator.pop(context);
                    onEntrenar();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
