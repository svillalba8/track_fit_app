import 'package:flutter/material.dart';

import '../../../widgets/custom_button.dart';

/// Página que muestra las estadísticas de un entrenamiento basado en una rutina.
/// - [routineName]: nombre de la rutina mostrada en el AppBar.
/// - [exercises]: lista de mapas con datos de ejercicios realizados.
/// - [totalRestTime]: tiempo total de descanso en segundos.
/// - [totalWorkoutTime]: tiempo total de entrenamiento en segundos.
class WorkoutStatisticsPage extends StatelessWidget {
  /// Nombre de la rutina para el título de la página.
  final String routineName;

  /// Lista de ejercicios con sus detalles: series, repeticiones y referencia al ejercicio.
  final List<Map<String, dynamic>> exercises;

  /// Tiempo total de descanso acumulado (en segundos).
  final int totalRestTime;

  /// Tiempo total de entrenamiento acumulado (en segundos).
  final int totalWorkoutTime;

  /// Constructor con parámetros obligatorios para inicializar la página.
  const WorkoutStatisticsPage({
    super.key,
    required this.routineName,
    required this.exercises,
    required this.totalRestTime,
    required this.totalWorkoutTime,
  });

  /// Da formato legible a una duración expresada en segundos,
  /// convirtiéndola en minutos y segundos.
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return minutes > 0 ? '${minutes}m ${secs}s' : '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos tema y esquema de colores actual.
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Barra superior con el nombre de la rutina.
      appBar: AppBar(
        title: Text('Estadísticas: $routineName'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la sección de ejercicios.
            Text(
              'Ejercicios realizados',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Lista expandida de tarjetas con cada ejercicio.
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (ctx, index) {
                  final exercise = exercises[index];
                  final ej = exercise['ejercicio'] ?? {};
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      // Icono representativo genérico.
                      leading: Icon(
                        Icons.fitness_center,
                        color: colorScheme.primary,
                        size: 32,
                      ),
                      // Nombre del ejercicio.
                      title: Text(
                        ej['nombre'] ?? 'Sin nombre',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Subtítulo con series y repeticiones.
                      subtitle: Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 18,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise['series']} series',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.format_list_numbered,
                            size: 18,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise['repeticiones']} repeticiones',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 30, thickness: 1.2),
            // Fila con tiempo total de entrenamiento.
            Row(
              children: [
                Icon(Icons.timer, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tiempo total entrenado:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(totalWorkoutTime),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Fila con tiempo total de descanso.
            Row(
              children: [
                Icon(Icons.timer_off, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tiempo total descansado:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(totalRestTime),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Botón para volver a la pantalla anterior.
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Volver',
                actualTheme: theme,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
