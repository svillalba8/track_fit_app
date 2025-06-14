import 'dart:async';

import 'package:flutter/material.dart';

import '../../../widgets/custom_button.dart';

/// Página que gestiona la sesión de entrenamiento de una rutina,
/// incluyendo descansos automáticos y registro de tiempos.
/// - [routineName]: nombre de la rutina mostrada en el AppBar.
/// - [exercises]: lista de mapas con datos de cada ejercicio (incluye campo 'ejercicio').
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
  /// Índice del ejercicio actual.
  int currentIndex = 0;

  /// Duración fija del descanso entre ejercicios (en segundos).
  static const int restDuration = 180;

  /// Segundos restantes de descanso.
  int restTimeLeft = restDuration;

  /// Indica si se está en fase de descanso.
  bool isResting = false;

  /// Timer periódico para gestionar la cuenta atrás del descanso.
  Timer? restTimer;

  /// Acumulado de segundos de descanso.
  int totalRestTime = 0;

  /// Acumulado de segundos de ejercicio.
  int totalWorkoutTime = 0;

  /// Inicia el temporizador de descanso y actualiza estado cada segundo.
  void _startRest() {
    setState(() {
      isResting = true;
      restTimeLeft = restDuration;
    });

    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (restTimeLeft > 0) {
        // Reduce cuenta atrás y suma al total de descanso.
        setState(() {
          restTimeLeft--;
          totalRestTime++;
        });
      } else {
        // Al terminar, cancelamos el timer y avanzamos o finalizamos.
        restTimer?.cancel();
        if (currentIndex < widget.exercises.length - 1) {
          setState(() {
            currentIndex++;
            isResting = false;
          });
          // Añade tiempo de ejercicio del siguiente ítem.
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

  /// Suma la duración configurada del ejercicio actual al total de entrenamiento.
  void _addCurrentExerciseDuration() {
    final duracionNum = widget.exercises[currentIndex]['duracion'] ?? 0;
    final duracion = (duracionNum is num) ? duracionNum.toInt() : 0;
    totalWorkoutTime += duracion;
  }

  /// Maneja el avance al siguiente ejercicio o la finalización.
  void _nextExercise() {
    if (currentIndex < widget.exercises.length - 1) {
      _startRest();
    } else {
      _showCompletionDialog();
    }
  }

  /// Continúa la sesión tras interrumpir o finalizar el descanso.
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

  /// Salta el resto del descanso.
  void _skipRest() {
    _continueAfterRest();
  }

  @override
  void initState() {
    super.initState();
    // Al iniciar, acumula el tiempo del primer ejercicio si existe.
    if (widget.exercises.isNotEmpty) {
      _addCurrentExerciseDuration();
    }
  }

  /// Muestra un diálogo al completar todos los ejercicios.
  void _showCompletionDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: colorScheme.surface,
            title: Text(
              '¡Enhorabuena!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Has terminado el entrenamiento "${widget.routineName}".',
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              // Botón para ver un resumen de estadísticas.
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
              // Botón para cerrar y salir de la sesión.
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

  /// Muestra un diálogo con las estadísticas detalladas de la sesión.
  void _showStatisticsDialog() {
    final actualTheme = Theme.of(context);
    final colorScheme = actualTheme.colorScheme;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: colorScheme.surface,
            title: Text(
              'Estadísticas',
              style: actualTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejercicios realizados:',
                    style: actualTheme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  // Lista de ejercicios con series y repeticiones.
                  ...widget.exercises.map((exercise) {
                    final ejercicio = exercise['ejercicio'] ?? {};
                    final nombre = ejercicio['nombre'] ?? 'Sin nombre';
                    final series = exercise['series'] ?? 'N/A';
                    final repeticiones = exercise['repeticiones'] ?? 'N/A';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '- $nombre: $series series x $repeticiones repeticiones',
                        style: actualTheme.textTheme.bodyMedium,
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Tiempo total de descanso: $totalRestTime segundos',
                    style: actualTheme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tiempo total de entrenamiento: $totalWorkoutTime segundos',
                    style: actualTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            actions: [
              // Botón para cerrar estadísticas y volver al diálogo de finalización.
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CustomButton(
                  text: 'Cerrar',
                  actualTheme: actualTheme,
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
    // Cancelamos el timer de descanso si está activo.
    restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Obtiene datos del ejercicio actual o nulo.
    final currentExercise =
        widget.exercises.isNotEmpty ? widget.exercises[currentIndex] : null;
    final ejercicio =
        currentExercise != null ? currentExercise['ejercicio'] : {};

    return Scaffold(
      appBar: AppBar(
        title: Text('Entrenando: ${widget.routineName}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        // Si está descansando, muestra contador y botones de control.
        child:
            isResting
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
                    // Indicador de progreso o mensaje si no hay ejercicios.
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
                      // Tarjeta con detalles del ejercicio actual.
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                              Text(
                                'Repeticiones: ${currentExercise['repeticiones']}',
                              ),
                              Text(
                                'Duración: ${(currentExercise['duracion'] ?? 0).toInt()} segundos',
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Botón para avanzar o finalizar.
                    CustomButton(
                      text:
                          currentIndex < widget.exercises.length - 1
                              ? 'Siguiente'
                              : 'Finalizar',
                      actualTheme: theme,
                      onPressed:
                          widget.exercises.isEmpty ? () {} : _nextExercise,
                    ),
                  ],
                ),
      ),
    );
  }
}
