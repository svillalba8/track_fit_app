import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/exercise_type.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/selectable_animated_container.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../services/exercise_service.dart';
import '../services/routine_service.dart';

/// Muestra un formulario en un Modal Bottom Sheet para añadir un ejercicio a una rutina existente.
/// - [context]: BuildContext para mostrar el modal.
/// - [routine]: rutina a la que se añadirá el ejercicio.
/// - [exerciseService]: servicio para obtener los ejercicios disponibles.
/// - [routineService]: servicio para modificar la rutina.
/// - [onSaved]: callback tras guardar correctamente.
void showAddExerciseToRoutineForm(
  BuildContext context,
  Routine routine,
  ExerciseService exerciseService,
  RoutineService routineService,
  VoidCallback onSaved,
) async {
  // Obtenemos la lista de ejercicios del servicio.
  final exercises = await exerciseService.getExercises();

  // Variable para el ejercicio seleccionado (inicialmente ninguno).
  Exercise? selectedExercise;

  // Controladores de texto para series, repeticiones y duración.
  final seriesController = TextEditingController();
  final repsController = TextEditingController();
  final durationController = TextEditingController();

  // Si el contexto ya no está montado, salimos.
  if (!context.mounted) return;
  final ThemeData actualTheme = Theme.of(context);

  // Agrupamos ejercicios por tipo para mostrarlos en secciones.
  final Map<ExerciseType, List<Exercise>> exercisesByType = {};
  for (var ex in exercises) {
    exercisesByType.putIfAbsent(ex.tipo, () => []).add(ex);
  }

  /// Retorna el icono asociado a cada tipo de ejercicio.
  IconData iconForType(ExerciseType type) {
    switch (type) {
      case ExerciseType.fuerza:
        return Icons.fitness_center;
      case ExerciseType.cardio:
        return Icons.directions_run;
      case ExerciseType.intenso:
        return Icons.flash_on;
    }
  }

  // Despliega el Modal Bottom Sheet con scroll controlado.
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: actualTheme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(context);
          // Habilita el botón cuando se ha seleccionado un ejercicio.
          final isButtonEnabled = selectedExercise != null;

          return Padding(
            // Ajusta el padding inferior al teclado.
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                opacity: 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título con el nombre de la rutina.
                    Text(
                      'Añadir ejercicio a "${routine.nombre}"',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Para cada tipo de ejercicio, si hay ejercicios de ese tipo...
                    for (var type in ExerciseType.values) ...[
                      if (exercisesByType[type]?.isNotEmpty ?? false) ...[
                        // Encabezado de sección con icono y nombre del tipo.
                        Row(
                          children: [
                            Icon(
                              iconForType(type),
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type.name[0].toUpperCase() +
                                  type.name.substring(1),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Wrap con opciones seleccionables de ejercicios.
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children:
                              exercisesByType[type]!.map((exercise) {
                                final isSelected = selectedExercise == exercise;
                                return SelectableAnimatedContainer(
                                  // Cambia selección al pulsar.
                                  onTap: () {
                                    setState(() {
                                      selectedExercise =
                                          isSelected ? null : exercise;
                                    });
                                  },
                                  isSelected: isSelected,
                                  selectedColor: theme.colorScheme.primary,
                                  unselectedColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  selectedBorderColor:
                                      theme.colorScheme.primary,
                                  unselectedBorderColor:
                                      theme.colorScheme.outline,
                                  selectedShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(12),
                                  child: Text(
                                    exercise.nombre,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? theme.colorScheme.onPrimary
                                              : theme.colorScheme.onSurface,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],

                    // Campo para número de series.
                    TextField(
                      controller: seriesController,
                      decoration: InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Campo para repeticiones.
                    TextField(
                      controller: repsController,
                      decoration: InputDecoration(
                        labelText: 'Repeticiones',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Campo para duración en segundos.
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duración (segundos)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    // Botón Guardar con opacidad según habilitación.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isButtonEnabled ? 1 : 0.5,
                      child: CustomButton(
                        text: 'Guardar',
                        actualTheme: theme,
                        onPressed:
                            isButtonEnabled
                                ? () async {
                                  // Llama al servicio para añadir el ejercicio a la rutina.
                                  await routineService.addExerciseToRoutine(
                                    routineId: routine.id,
                                    exerciseId: selectedExercise!.id,
                                    series:
                                        int.tryParse(seriesController.text) ??
                                        0,
                                    reps:
                                        int.tryParse(repsController.text) ?? 0,
                                    duration:
                                        int.tryParse(durationController.text) ??
                                        0,
                                  );
                                  if (!context.mounted) return;
                                  ctx.pop();
                                  onSaved();
                                }
                                : () {}, // Handler vacío si no está habilitado.
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
