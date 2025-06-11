import 'package:flutter/material.dart';

import '../../../core/enums/exercise_type.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/selectable_animated_container.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';
import '../services/exercise_service.dart';
import '../services/routine_service.dart';
void showAddExerciseToRoutineForm(
    BuildContext context,
    Routine routine,
    ExerciseService exerciseService,
    RoutineService routineService,
    VoidCallback onSaved,
    ) async {
  final exercises = await exerciseService.getExercises();
  Exercise? selectedExercise;
  final seriesController = TextEditingController();
  final repsController = TextEditingController();
  final durationController = TextEditingController();

  final Map<ExerciseType, List<Exercise>> exercisesByType = {};
  for (var ex in exercises) {
    exercisesByType.putIfAbsent(ex.tipo, () => []).add(ex);
  }

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

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(context);
          final isButtonEnabled = selectedExercise != null;

          return Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Añadir ejercicio a "${routine.nombre}"',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    for (var type in ExerciseType.values) ...[
                      if (exercisesByType[type]?.isNotEmpty ?? false) ...[
                        Row(
                          children: [
                            Icon(iconForType(type), color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              type.name[0].toUpperCase() + type.name.substring(1),
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: exercisesByType[type]!.map((exercise) {
                            final isSelected = selectedExercise == exercise;
                            return SelectableAnimatedContainer(
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  selectedExercise = isSelected ? null : exercise;
                                });
                              },
                              selectedColor: theme.colorScheme.primary,
                              unselectedColor: theme.colorScheme.surfaceVariant ?? theme.colorScheme.surface,
                              selectedBorderColor: theme.colorScheme.primary,
                              unselectedBorderColor: theme.colorScheme.outline,
                              selectedShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.6),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                              borderRadius: BorderRadius.circular(12),
                              child: Text(
                                exercise.nombre,
                                style: TextStyle(
                                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],

                    TextField(
                      controller: seriesController,
                      decoration: InputDecoration(
                        labelText: 'Series',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: repsController,
                      decoration: InputDecoration(
                        labelText: 'Repeticiones',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'Duración (segundos)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 24),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isButtonEnabled ? 1 : 0.5,
                      child: CustomButton(
                        text: 'Guardar',
                        actualTheme: theme,
                        onPressed: isButtonEnabled
                            ? () async {
                          await routineService.addExerciseToRoutine(
                            routineId: routine.id,
                            exerciseId: selectedExercise!.id,
                            series: int.tryParse(seriesController.text) ?? 0,
                            reps: int.tryParse(repsController.text) ?? 0,
                            duration: int.tryParse(durationController.text) ?? 0,
                          );
                          Navigator.pop(ctx);
                          onSaved();
                        }
                            : () {},
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
