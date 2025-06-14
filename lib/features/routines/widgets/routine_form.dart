import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/custom_button.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

/// Muestra un formulario en un Modal Bottom Sheet para crear o editar una rutina.
/// - [context]: contexto de Flutter para mostrar el modal.
/// - [service]: servicio encargado de las operaciones CRUD de rutinas.
/// - [onSaved]: callback que se ejecuta tras guardar correctamente.
/// - [routine]: objeto opcional; si se proporciona, el formulario se inicializa en modo edición.
void showRoutineForm(
  BuildContext context,
  RoutineService service,
  VoidCallback onSaved, {
  Routine? routine,
}) {
  // Controlador del campo de texto, inicializado con el nombre de la rutina (si existe).
  final nameController = TextEditingController(text: routine?.nombre ?? '');

  // Despliega un Modal Bottom Sheet con scroll controlado y forma personalizada.
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      // Utilizamos StatefulBuilder para actualizar el estado interno del contenido.
      return StatefulBuilder(
        builder: (ctx, setState) {
          final theme = Theme.of(context);
          // Habilita el botón si el campo de texto no está vacío.
          final isButtonEnabled = nameController.text.trim().isNotEmpty;

          return Padding(
            // Ajuste de padding para evitar overlap con el teclado.
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
                // Título dinámico según modo creación o edición.
                Text(
                  routine == null ? 'Nueva Rutina' : 'Editar Rutina',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // Campo para introducir el nombre de la rutina.
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Actualiza la UI (estado) al modificar el texto.
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 30),
                // Botón personalizado para guardar la rutina.
                CustomButton(
                  text: 'Guardar',
                  actualTheme: theme,
                  onPressed:
                      isButtonEnabled
                          ? () {
                            // Obtenemos el nombre limpio.
                            final name = nameController.text.trim();

                            // Llamada al servicio: crear o actualizar según corresponda.
                            final future =
                                routine == null
                                    ? service.createRoutine(name)
                                    : service.updateRoutine(routine.id, name);

                            // Una vez completada la operación, cerramos el modal y
                            // ejecutamos el callback onSaved.
                            future.then((_) {
                              if (!context.mounted) return;
                              context.pop();
                              onSaved();
                            });
                          }
                          : () {}, // Handler vacío cuando está deshabilitado.
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
