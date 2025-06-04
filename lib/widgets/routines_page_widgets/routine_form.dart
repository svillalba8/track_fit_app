import 'package:flutter/material.dart';
import '../../../models/routine_model.dart';
import '../../../services/routine_service.dart';
import '../custom_button.dart';

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
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
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
                  routine == null ? 'Nueva Rutina' : 'Editar Rutina',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20),
                // Aquí se pasa una función sincrónica
                CustomButton(
                  text: 'Guardar',
                  onPressed: isButtonEnabled
                      ? () {
                    final name = nameController.text.trim();
                    // Ejecuta la función async sin await
                    final future = routine == null
                        ? service.createRoutine(name)
                        : service.updateRoutine(routine.id, name);

                    future.then((_) {
                      Navigator.pop(ctx);
                      onSaved();
                    });
                  }
                      : () {}, // si quieres que no haga nada cuando no está habilitado
                  actualTheme: Theme.of(context), // recuerda que CustomButton lo requiere
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
