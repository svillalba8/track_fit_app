import 'package:flutter/material.dart';
import '../../models/routines_models/exercise_model.dart';
import '../../models/routines_models/routine_model.dart';
import '../../services/routines_services/exercise_service.dart';
import '../../services/routines_services/routine_service.dart';
import '../custom_button.dart';

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Añadir ejercicio a "${routine.nombre}"',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Selecciona un ejercicio',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: exercises.map((exercise) {
                      final isSelected = selectedExercise == exercise;

                      return ChoiceChip(
                        label: Text(
                          exercise.nombre,
                          style: TextStyle(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surfaceVariant ?? theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (_) {
                          setState(() {
                            selectedExercise = isSelected ? null : exercise;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

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

                  CustomButton(
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
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
