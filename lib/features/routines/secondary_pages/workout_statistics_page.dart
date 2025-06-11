import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';

class WorkoutStatisticsPage extends StatelessWidget {
  final String routineName;
  final List<Map<String, dynamic>> exercises;
  final int totalRestTime; // en segundos
  final int totalWorkoutTime; // en segundos

  const WorkoutStatisticsPage({
    super.key,
    required this.routineName,
    required this.exercises,
    required this.totalRestTime,
    required this.totalWorkoutTime,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return minutes > 0 ? '${minutes}m ${secs}s' : '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
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
            Text(
              'Ejercicios realizados',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (ctx, index) {
                  final exercise = exercises[index];
                  final ej = exercise['ejercicio'] ?? {};
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: Icon(Icons.fitness_center, color: colorScheme.primary, size: 32),
                      title: Text(
                        ej['nombre'] ?? 'Sin nombre',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(Icons.repeat, size: 18, color: colorScheme.secondary),
                          const SizedBox(width: 4),
                          Text(
                            '${exercise['series']} series',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.format_list_numbered, size: 18, color: colorScheme.secondary),
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
            Row(
              children: [
                Icon(Icons.timer, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tiempo total entrenado:',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(totalWorkoutTime),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.timer_off, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Tiempo total descansado:',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDuration(totalRestTime),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
