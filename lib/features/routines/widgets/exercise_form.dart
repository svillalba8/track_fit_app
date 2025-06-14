import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/exercise_type.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/selectable_animated_container.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

/// Muestra un formulario en un Modal Bottom Sheet para crear o editar un ejercicio.
/// - [context]: contexto de Flutter para mostrar el modal.
/// - [service]: servicio encargado de las operaciones CRUD de ejercicios.
/// - [onSaved]: callback que se ejecuta tras guardar correctamente.
/// - [exercise]: objeto opcional; si se proporciona, inicializa el formulario en modo edición.
void showExerciseForm(
  BuildContext context,
  ExerciseService service,
  VoidCallback onSaved, {
  Exercise? exercise,
}) {
  // Controladores de texto para nombre y descripción, inicializados con valores existentes si procede.
  final nameController = TextEditingController(text: exercise?.nombre ?? '');
  final descController = TextEditingController(
    text: exercise?.descripcion ?? '',
  );

  // Estado local para el tipo de ejercicio seleccionado; por defecto "fuerza" o el valor actual.
  ExerciseType selectedType = exercise?.tipo ?? ExerciseType.fuerza;

  // Despliega el Modal Bottom Sheet con capacidad de scroll al mostrarse el teclado.
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      // StatefulBuilder para gestionar internamente cambios de estado (texto y selección).
      return StatefulBuilder(
        builder: (ctx, setState) {
          final actuaTheme = Theme.of(context);
          final colorScheme = actuaTheme.colorScheme;
          // Determina si el botón de "Guardar" está habilitado (nombre no vacío).
          final isButtonEnabled = nameController.text.trim().isNotEmpty;

          // Función interna que retorna el icono correspondiente a cada tipo de ejercicio.
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
            // Padding dinámico para evitar superposición con el teclado.
            padding: EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              // Permite scroll cuando el contenido excede el espacio vertical.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título que varía entre "Nuevo Ejercicio" o "Editar Ejercicio".
                  Text(
                    exercise == null ? 'Nuevo Ejercicio' : 'Editar Ejercicio',
                    style: actuaTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Campo de texto para el nombre del ejercicio.
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // Actualiza el estado para habilitar/deshabilitar el botón.
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  // Campo de texto para la descripción del ejercicio.
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
                  // Etiqueta para la sección de selección de tipo.
                  Text(
                    'Tipo de ejercicio',
                    style: actuaTheme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Wrap para mostrar opciones de tipo de ejercicio en fila múltiple.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ExerciseType.values.map((type) {
                          final isSelected = type == selectedType;
                          return SelectableAnimatedContainer(
                            // Propiedades visuales según estado seleccionado o no.
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedType = type),
                            selectedColor: colorScheme.tertiary,
                            unselectedColor: colorScheme.surface.withValues(
                              alpha: 0.05,
                            ),
                            selectedBorderColor: colorScheme.tertiary,
                            unselectedBorderColor: colorScheme.onSurface
                                .withValues(alpha: 0.2),
                            selectedShadow: [
                              BoxShadow(
                                color: colorScheme.tertiary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icono representativo del tipo.
                                Icon(
                                  iconForType(type),
                                  size: 18,
                                  color:
                                      isSelected
                                          ? colorScheme.onTertiary
                                          : colorScheme.onSurface.withValues(
                                            alpha: 0.8,
                                          ),
                                ),
                                const SizedBox(width: 6),
                                // Texto animado que cambia estilo según selección.
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? colorScheme.onTertiary
                                            : colorScheme.onSurface.withValues(
                                              alpha: 0.8,
                                            ),
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                  child: Text(
                                    // Capitaliza la primera letra del nombre del tipo.
                                    type.name[0].toUpperCase() +
                                        type.name.substring(1),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 30),
                  // Botón "Guardar" con opacidad animada según habilitación.
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: isButtonEnabled ? 1 : 0.5,
                    child: CustomButton(
                      text: 'Guardar',
                      actualTheme: actuaTheme,
                      onPressed:
                          isButtonEnabled
                              ? () {
                                // Obtiene valores limpios de los campos.
                                final name = nameController.text.trim();
                                final desc = descController.text.trim();

                                // Llama al servicio para crear o actualizar.
                                final future =
                                    exercise == null
                                        ? service.createExercise(
                                          name,
                                          selectedType,
                                          desc,
                                        )
                                        : service.updateExercise(
                                          exercise.id,
                                          name,
                                          selectedType,
                                          desc,
                                        );

                                // Al completarse, cierra el modal y dispara onSaved.
                                future.then((_) {
                                  if (!context.mounted) return;
                                  context.pop();
                                  onSaved();
                                });
                              }
                              : () {}, // Handler vacío si el botón está deshabilitado.
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
