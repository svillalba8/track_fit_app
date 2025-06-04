import 'package:flutter/material.dart';
import '../../../core/enums/exercise_type.dart';
import '../../models/routines_models/exercise_model.dart';
import '../../services/routines_services/exercise_service.dart';
import '../custom_button.dart';

void showExerciseForm(
    BuildContext context,
    ExerciseService service,
    VoidCallback onSaved, {
      Exercise? exercise,
    }) {
  final nameController = TextEditingController(text: exercise?.nombre ?? '');
  final descController = TextEditingController(text: exercise?.descripcion ?? '');
  ExerciseType selectedType = exercise?.tipo ?? ExerciseType.fuerza;

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
          final colorScheme = theme.colorScheme;
          final isButtonEnabled = nameController.text.trim().isNotEmpty;

          return Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise == null ? 'Nuevo Ejercicio' : 'Editar Ejercicio',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                Text(
                  'Tipo de ejercicio',
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ExerciseType.values.map((type) {
                    final isSelected = type == selectedType;

                    IconData icon;
                    switch (type) {
                      case ExerciseType.fuerza:
                        icon = Icons.fitness_center;
                        break;
                      case ExerciseType.cardio:
                        icon = Icons.directions_run;
                        break;
                      case ExerciseType.intenso:
                        icon = Icons.whatshot;
                        break;
                    }

                    return ChoiceChip(
                      selected: isSelected,
                      onSelected: (_) => setState(() => selectedType = type),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: isSelected
                                ? colorScheme.onTertiary
                                : colorScheme.onSurface.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            type.name[0].toUpperCase() + type.name.substring(1),
                            style: TextStyle(
                              color: isSelected
                                  ? colorScheme.onTertiary
                                  : colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                      selectedColor: colorScheme.tertiary,
                      backgroundColor: colorScheme.surface.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.tertiary
                              : colorScheme.onSurface.withOpacity(0.2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Guardar',
                  actualTheme: theme,
                  onPressed: isButtonEnabled
                      ? () {
                    final name = nameController.text.trim();
                    final desc = descController.text.trim();

                    final future = exercise == null
                        ? service.createExercise(name, selectedType, desc)
                        : service.updateExercise(exercise.id, name, selectedType, desc);

                    future.then((_) {
                      Navigator.pop(ctx);
                      onSaved();
                    });
                  }
                      : () {}, // Deshabilitado si vacío
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
