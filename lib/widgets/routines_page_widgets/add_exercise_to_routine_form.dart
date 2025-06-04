import 'package:flutter/material.dart';
import '../../../models/exercise_model.dart';
import '../../../models/routine_model.dart';
import '../../../services/exercise_service.dart';
import '../../../services/routine_service.dart';

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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final isButtonEnabled = selectedExercise != null;

          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Wrap(
              children: [
                Text(
                  'Añadir ejercicio a ${routine.nombre}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButton<Exercise>(
                  isExpanded: true,
                  hint: const Text("Selecciona un ejercicio"),
                  value: selectedExercise,
                  items: exercises
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text(e.nombre)),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedExercise = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: seriesController,
                  decoration: const InputDecoration(labelText: 'Series'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duración (segundos)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
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
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Theme.of(context).colorScheme.onSurface.withOpacity(0.12);
                        }
                        return Theme.of(context).colorScheme.primary;
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
                        }
                        return Theme.of(context).colorScheme.onPrimary;
                      },
                    ),
                    padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
