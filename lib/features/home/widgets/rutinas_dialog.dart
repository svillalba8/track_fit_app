import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/custom_button.dart';
import '../../routines/models/routine_model.dart';

// Diálogo que muestra la lista de rutinas disponibles y permite iniciar el entrenamiento
class RutinasDialog extends StatelessWidget {
  // Lista de todas las rutinas a mostrar
  final List<Routine> todasLasRutinas;
  // Callback que se ejecuta al pulsar el botón de entrenar
  final VoidCallback onEntrenar;

  const RutinasDialog({
    super.key,
    required this.todasLasRutinas,
    required this.onEntrenar,
  });

  @override
  Widget build(BuildContext context) {
    // Tema actual para acceder a colores y estilos
    final actualTheme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.white, // Color de fondo del diálogo
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Bordes redondeados
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Espacio interior
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajustar altura al contenido
          children: [
            // Título del diálogo
            const Text(
              'Tus Rutinas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista desplazable de rutinas
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: todasLasRutinas.length,
                itemBuilder: (context, index) {
                  final rutina = todasLasRutinas[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.fitness_center,
                      color: Colors.black54, // Icono de rutina
                    ),
                    title: Text(
                      rutina.nombre, // Nombre de la rutina
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Botones de acción: Volver y Entrenar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón para cerrar el diálogo sin acción
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Volver',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Botón principal para iniciar la rutina seleccionada
                CustomButton(
                  text: '¡Vamos a entrenar!',
                  actualTheme: actualTheme,
                  onPressed: () {
                    context.pop(); // Cierra el diálogo
                    onEntrenar(); // Lanza el callback de entrenamiento
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
