import 'package:flutter/material.dart';
import '../../../core/enums/exercise_type.dart';
import '../../../models/exercise_model.dart';
import '../../../services/exercise_service.dart';
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
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(context);
          final isButtonEnabled = nameController.text.trim().isNotEmpty;

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
                  exercise == null ? 'Nuevo Ejercicio' : 'Editar Ejercicio',
                  style: theme.textTheme.titleMedium,
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                DropdownButton<ExerciseType>(
                  isExpanded: true,
                  value: selectedType,
                  items: ExerciseType.values
                      .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 20),
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
                      : () {}, // función vacía si no está habilitado
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
