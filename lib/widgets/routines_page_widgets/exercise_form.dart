// widgets/exercise_form.dart
import 'package:flutter/material.dart';
import '../../core/enums/exercise_type.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

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
      return Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Wrap(
          children: [
            Text(exercise == null ? 'Nuevo Ejercicio' : 'Editar Ejercicio',
                style: Theme.of(context).textTheme.titleMedium),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
            DropdownButton<ExerciseType>(
              isExpanded: true,
              value: selectedType,
              items: ExerciseType.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (value) => selectedType = value!,
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final name = nameController.text.trim();
                final desc = descController.text.trim();
                if (exercise == null) {
                  await service.createExercise(name, selectedType, desc);
                } else {
                  await service.updateExercise(exercise.id, name, selectedType, desc);
                }
                Navigator.pop(ctx);
                onSaved();
              },
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            )
          ],
        ),
      );
    },
  );
}
