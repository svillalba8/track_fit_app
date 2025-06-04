import 'dart:async';
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';

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
  static const int restDuration = 30;
  int restTimeLeft = restDuration;
  bool isResting = false;
  Timer? restTimer;

  void _startRest() {
    setState(() {
      isResting = true;
      restTimeLeft = restDuration;
    });

    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimeLeft > 0) {
        setState(() {
          restTimeLeft--;
        });
      } else {
        restTimer?.cancel();
        if (currentIndex < widget.exercises.length - 1) {
          setState(() {
            currentIndex++;
            isResting = false;
          });
        } else {
          setState(() {
            isResting = false;
          });
          _showCompletionDialog();
        }
      }
    });
  }

  void _nextExercise() {
    if (currentIndex < widget.exercises.length - 1) {
      _startRest();
    } else {
      _showCompletionDialog();
    }
  }

  void _continueAfterRest() {
    restTimer?.cancel();
    if (currentIndex < widget.exercises.length - 1) {
      setState(() {
        currentIndex++;
        isResting = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _skipRest() {
    _continueAfterRest();
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
  void dispose() {
    restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currentExercise = widget.exercises.isNotEmpty
        ? widget.exercises[currentIndex]
        : null;

    final ejercicio = currentExercise != null ? currentExercise['ejercicio'] : {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenando: ${widget.routineName}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isResting
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Descanso: $restTimeLeft segundos',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CustomButton(
              text: 'Continuar',
              actualTheme: theme,
              onPressed: restTimeLeft == 0 ? _continueAfterRest : () {},
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Saltar descanso',
              actualTheme: theme,
              onPressed: _skipRest,
            ),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.exercises.isNotEmpty
                  ? 'Ejercicio ${currentIndex + 1} de ${widget.exercises.length}'
                  : 'No hay ejercicios disponibles.',
              style: theme.textTheme.titleMedium?.copyWith(
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
                        style: theme.textTheme.titleLarge,
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
            CustomButton(
              text: currentIndex < widget.exercises.length - 1 ? 'Siguiente' : 'Finalizar',
              actualTheme: theme,
              onPressed: widget.exercises.isEmpty ? () {} : _nextExercise,
            ),
          ],
        ),
      ),
    );
  }
}
