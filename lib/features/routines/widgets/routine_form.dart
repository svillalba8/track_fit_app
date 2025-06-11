import 'package:flutter/material.dart';
import '../../../widgets/custom_button.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';
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
                  routine == null ? 'Nueva Rutina' : 'Editar Rutina',
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
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Guardar',
                  actualTheme: theme,
                  onPressed: isButtonEnabled
                      ? () {
                    final name = nameController.text.trim();

                    final future = routine == null
                        ? service.createRoutine(name)
                        : service.updateRoutine(routine.id, name);

                    future.then((_) {
                      Navigator.pop(ctx);
                      onSaved();
                    });
                  }
                      : () {}, // Botón deshabilitado visualmente
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
