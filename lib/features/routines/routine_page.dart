import 'package:flutter/material.dart';
import '../../core/enums/exercise_type.dart';
import '../../models/exercise_model.dart';
import '../../models/routine_model.dart';
import '../../services/ejercicio_seleccionado_service.dart';
import '../../services/exercise_service.dart';
import '../../services/routine_service.dart';
import '../../widgets/custom_button.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final _exerciseService = ExerciseService();
  final _routineService = RoutineService();
  List<Exercise> _exercises = [];
  List<Routine> _routines = [];
  bool _showExercises = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadRoutines();
  }

  Future<void> _loadExercises() async {
    final ejercicios = await _exerciseService.getExercises();
    setState(() {
      _exercises = ejercicios;
    });
  }

  Future<void> _loadRoutines() async {
    final rutinas = await _routineService.getRoutines();
    setState(() {
      _routines = rutinas;
    });
  }

  Future<void> _showCreateExerciseDialog() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    ExerciseType selectedType = ExerciseType.fuerza;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Ejercicio"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButton<ExerciseType>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: ExerciseType.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo.name),
                );
              }).toList(),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _exerciseService.createExercise(
                nombreController.text,
                selectedType,
                descripcionController.text,
              );
              await _loadExercises();
              Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditExerciseDialog(Exercise exercise) async {
    final nombreController = TextEditingController(text: exercise.nombre);
    final descripcionController = TextEditingController(text: exercise.descripcion ?? '');
    ExerciseType selectedType = exercise.tipo;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Ejercicio"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            DropdownButton<ExerciseType>(
              value: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
              items: ExerciseType.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Text(tipo.name),
                );
              }).toList(),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _exerciseService.updateExercise(
                exercise.id,
                nombreController.text,
                selectedType,
                descripcionController.text,
              );
              await _loadExercises();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditRoutineDialog(Routine routine) async {
    final nombreController = TextEditingController(text: routine.nombre);
    final ejerciciosDisponibles = await _exerciseService.getExercises();
    final ejerciciosEnRutina = await _routineService.getExercisesForRoutine(routine.id);

    if (ejerciciosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay ejercicios disponibles para editar')),
      );
      return;
    }

    final ejerciciosSeleccionados = <EjercicioSeleccionadoService>[];

    // Cargar ejercicios existentes en la rutina
    for (var ejercicio in ejerciciosEnRutina) {
      final eSel = EjercicioSeleccionadoService(ejercicio);
      // Aquí deberías cargar los valores actuales (series, repeticiones, duración)
      // Esto depende de cómo obtengas estos datos de la rutina existente
      ejerciciosSeleccionados.add(eSel);
    }

    Exercise? selectedExercise = ejerciciosDisponibles.first;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre rutina'),
                ),
                DropdownButton<Exercise>(
                  value: selectedExercise,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedExercise = value!;
                    });
                  },
                  items: ejerciciosDisponibles.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e.nombre));
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedExercise != null &&
                        !ejerciciosSeleccionados.any((e) => e.ejercicio.id == selectedExercise!.id)) {
                      setState(() {
                        ejerciciosSeleccionados.add(EjercicioSeleccionadoService(selectedExercise!));
                      });
                    }
                  },
                  child: const Text('Añadir ejercicio'),
                ),
                ...ejerciciosSeleccionados.map((eSel) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(eSel.ejercicio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: eSel.seriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Series'),
                        ),
                        TextField(
                          controller: eSel.repeticionesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Repeticiones'),
                        ),
                        TextField(
                          controller: eSel.duracionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duración (segundos)'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ejerciciosSeleccionados.remove(eSel);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debes ingresar un nombre para la rutina')),
                  );
                  return;
                }

                try {
                  // Actualizar nombre de la rutina
                  await _routineService.updateRoutine(routine.id, nombre);

                  // Eliminar todos los ejercicios actuales de la rutina
                  await _routineService.removeAllExercisesFromRoutine(routine.id);

                  // Añadir los ejercicios seleccionados
                  for (var eSel in ejerciciosSeleccionados) {
                    final series = int.tryParse(eSel.seriesController.text.trim()) ?? 0;
                    final repes = int.tryParse(eSel.repeticionesController.text.trim()) ?? 0;
                    final duracion = int.tryParse(eSel.duracionController.text.trim());

                    await _routineService.addExerciseToRoutine(
                      rutinaId: routine.id,
                      ejercicioId: eSel.ejercicio.id,
                      series: series,
                      repeticiones: repes,
                      duracion: duracion?.toDouble(),
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rutina actualizada correctamente')));
                    await _loadRoutines();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar rutina: $e')));
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoutineDialog() async {
    final nombreController = TextEditingController();
    final ejerciciosDisponibles = await _exerciseService.getExercises();

    if (ejerciciosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes crear al menos un ejercicio.')),
      );
      return;
    }

    final ejerciciosSeleccionados = <EjercicioSeleccionadoService>[];
    Exercise? selectedExercise = ejerciciosDisponibles.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre rutina'),
                ),
                DropdownButton<Exercise>(
                  value: selectedExercise,
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedExercise = value!;
                    });
                  },
                  items: ejerciciosDisponibles.map((e) {
                    return DropdownMenuItem(value: e, child: Text(e.nombre));
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedExercise != null &&
                        !ejerciciosSeleccionados.any((e) => e.ejercicio.id == selectedExercise!.id)) {
                      setState(() {
                        ejerciciosSeleccionados.add(EjercicioSeleccionadoService(selectedExercise!));
                      });
                    }
                  },
                  child: const Text('Añadir ejercicio'),
                ),
                ...ejerciciosSeleccionados.map((eSel) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(eSel.ejercicio.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: eSel.seriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Series'),
                        ),
                        TextField(
                          controller: eSel.repeticionesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Repeticiones'),
                        ),
                        TextField(
                          controller: eSel.duracionController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Duración (segundos)'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              ejerciciosSeleccionados.remove(eSel);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                final nombre = nombreController.text.trim();

                if (nombre.isEmpty || ejerciciosSeleccionados.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debes ingresar un nombre y al menos un ejercicio')),
                  );
                  return;
                }

                final nuevaRutina = await _routineService.createRoutine(nombre);

                for (var eSel in ejerciciosSeleccionados) {
                  final series = int.tryParse(eSel.seriesController.text.trim()) ?? 0;
                  final repes = int.tryParse(eSel.repeticionesController.text.trim()) ?? 0;
                  final duracion = int.tryParse(eSel.duracionController.text.trim());

                  await _routineService.addExerciseToRoutine(
                    rutinaId: nuevaRutina!.id,
                    ejercicioId: eSel.ejercicio.id,
                    series: series,
                    repeticiones: repes,
                    duracion: duracion?.toDouble(),
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rutina creada con ejercicios')));
                  await _loadRoutines();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRoutine(int routineId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta rutina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _routineService.deleteRoutine(routineId);
        await _loadRoutines();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rutina eliminada correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar rutina: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas y Ejercicios')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showExercises = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showExercises ? Theme.of(context).primaryColor : Colors.grey,
                ),
                child: const Text('Ejercicios'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showExercises = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !_showExercises ? Theme.of(context).primaryColor : Colors.grey,
                ),
                child: const Text('Rutinas'),
              ),
            ],
          ),
          CustomButton(
            text: _showExercises ? 'Crear Ejercicio' : 'Crear Rutina',
            onPressed: _showExercises ? _showCreateExerciseDialog : _showCreateRoutineDialog,
            actualTheme: Theme.of(context),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _showExercises
                ? _buildExercisesList()
                : _buildRoutinesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return _exercises.isEmpty
        ? const Center(child: Text('No hay ejercicios'))
        : ListView.builder(
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final ejercicio = _exercises[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              ejercicio.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              ejercicio.tipo.name,
              style: TextStyle(color: Colors.grey[700]),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () {
                    _showEditExerciseDialog(ejercicio);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Eliminar ejercicio "${ejercicio.nombre}"?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar')),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      try {
                        await _exerciseService.deleteExercise(ejercicio.id);
                        await _loadExercises();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ejercicio eliminado')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error al eliminar ejercicio: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoutinesList() {
    return _routines.isEmpty
        ? const Center(child: Text('No hay rutinas'))
        : ListView.builder(
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              routine.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueAccent),
                  onPressed: () => _showEditRoutineDialog(routine),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteRoutine(routine.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}