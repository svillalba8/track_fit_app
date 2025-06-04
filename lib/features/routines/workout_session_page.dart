import 'package:flutter/material.dart';

class WorkoutSessionPage extends StatefulWidget {
  final String routineName;
  final List<Map<String, dynamic>> exercises;

  const WorkoutSessionPage({
    super.key,
    required this.routineName,
    required this.exercises,
  });

  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  int currentIndex = 0;

  void _nextExercise() {
    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Enhorabuena!'),
        content: Text('Has terminado el entrenamiento "${widget.routineName}".'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // Salir de la sesión
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentExercise = widget.exercises.isNotEmpty
        ? widget.exercises[currentIndex]
        : null;

    final ejercicio = currentExercise != null ? currentExercise['ejercicio'] : {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenando: ${widget.routineName}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercises.isNotEmpty
                  ? 'Ejercicio ${currentIndex + 1} de ${widget.exercises.length}'
                  : 'No hay ejercicios disponibles.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: widget.exercises.isNotEmpty ? null : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            if (currentExercise != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ejercicio['nombre'] ?? 'Sin nombre',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text('Series: ${currentExercise['series']}'),
                      Text('Repeticiones: ${currentExercise['repeticiones']}'),
                      Text('Duración: ${currentExercise['duracion']} segundos'),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: widget.exercises.isEmpty ? null : _nextExercise,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(currentIndex < widget.exercises.length - 1 ? 'Siguiente' : 'Finalizar'),
            ),
          ],
        ),
      ),
    );
  }
}
