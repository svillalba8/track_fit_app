import 'package:flutter/material.dart';
import '../../../core/enums/exercise_type.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/selectable_animated_container.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

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

          IconData iconForType(ExerciseType type) {
            switch (type) {
              case ExerciseType.fuerza:
                return Icons.fitness_center;
              case ExerciseType.cardio:
                return Icons.directions_run;
              case ExerciseType.intenso:
                return Icons.whatshot;
            }
          }

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

                      return SelectableAnimatedContainer(
                        isSelected: isSelected,
                        onTap: () => setState(() => selectedType = type),
                        selectedColor: colorScheme.tertiary,
                        unselectedColor: colorScheme.surface.withOpacity(0.05),
                        selectedBorderColor: colorScheme.tertiary,
                        unselectedBorderColor: colorScheme.onSurface.withOpacity(0.2),
                        selectedShadow: [
                          BoxShadow(
                            color: colorScheme.tertiary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                        borderRadius: BorderRadius.circular(30),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              iconForType(type),
                              size: 18,
                              color: isSelected ? colorScheme.onTertiary : colorScheme.onSurface.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              style: TextStyle(
                                color: isSelected ? colorScheme.onTertiary : colorScheme.onSurface.withOpacity(0.8),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isButtonEnabled ? 1 : 0.5,
                    child: CustomButton(
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
                          : () {},
                    ),
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
