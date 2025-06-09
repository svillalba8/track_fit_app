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
  static const int restDuration = 180;
  int restTimeLeft = restDuration;
  bool isResting = false;
  Timer? restTimer;

  int totalRestTime = 0;
  int totalWorkoutTime = 0;

  void _startRest() {
    setState(() {
      isResting = true;
      restTimeLeft = restDuration;
    });

    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimeLeft > 0) {
        setState(() {
          restTimeLeft--;
          totalRestTime++;
        });
      } else {
        restTimer?.cancel();
        if (currentIndex < widget.exercises.length - 1) {
          setState(() {
            currentIndex++;
            isResting = false;
          });
          _addCurrentExerciseDuration();
        } else {
          setState(() {
            isResting = false;
          });
          _showCompletionDialog();
        }
      }
    });
  }

  void _addCurrentExerciseDuration() {
    final duracionNum = widget.exercises[currentIndex]['duracion'] ?? 0;
    final duracion = (duracionNum is num) ? duracionNum.toInt() : 0;
    totalWorkoutTime += duracion;
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
      _addCurrentExerciseDuration();
    } else {
      _showCompletionDialog();
    }
  }

  void _skipRest() {
    _continueAfterRest();
  }

  @override
  void initState() {
    super.initState();
    if (widget.exercises.isNotEmpty) {
      _addCurrentExerciseDuration();
    }
  }

  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        title: Text(
          '¡Enhorabuena!',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Has terminado el entrenamiento "${widget.routineName}".',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: CustomButton(
              text: 'Ver estadísticas',
              actualTheme: theme,
              onPressed: () {
                Navigator.of(ctx).pop();
                _showStatisticsDialog();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: CustomButton(
              text: 'Aceptar',
              actualTheme: theme,
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatisticsDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        title: Text(
          'Estadísticas',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ejercicios realizados:', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...widget.exercises.map((exercise) {
                final ejercicio = exercise['ejercicio'] ?? {};
                final nombre = ejercicio['nombre'] ?? 'Sin nombre';
                final series = exercise['series'] ?? 'N/A';
                final repeticiones = exercise['repeticiones'] ?? 'N/A';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '- $nombre: $series series x $repeticiones repeticiones',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              Text(
                'Tiempo total de descanso: $totalRestTime segundos',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tiempo total de entrenamiento: $totalWorkoutTime segundos',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomButton(
              text: 'Cerrar',
              actualTheme: theme,
              onPressed: () {
                Navigator.of(ctx).pop();
                _showCompletionDialog();
              },
            ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_bottom, size: 36),
                const SizedBox(width: 10),
                Text(
                  'Descanso: $restTimeLeft s',
                  style: theme.textTheme.headlineMedium,
                ),
              ],
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
                      Text('Duración: ${(currentExercise['duracion'] ?? 0).toInt()} segundos'),
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
