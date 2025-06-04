// widgets/routine_form.dart
import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../services/routine_service.dart';

void showRoutineForm(
    BuildContext context,
    RoutineService service,
    VoidCallback onSaved, {
      Routine? routine,
    }) {
  final nameController = TextEditingController(text: routine?.nombre ?? '');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
      ),
      child: Wrap(
        children: [
          Text(routine == null ? 'Nueva Rutina' : 'Editar Rutina',
              style: Theme.of(context).textTheme.titleMedium),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
          ElevatedButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              if (routine == null) {
                await service.createRoutine(name);
              } else {
                await service.updateRoutine(routine.id, name);
              }
              Navigator.pop(ctx);
              onSaved();
            },
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
