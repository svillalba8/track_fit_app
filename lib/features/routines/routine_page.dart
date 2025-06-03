import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final Map<int, List<Map<String, dynamic>>> _routineExercisesDetails = {};

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
    for (var rutina in rutinas) {
      final details = await _routineService.getRoutineExercisesDetails(rutina.id);
      _routineExercisesDetails[rutina.id] = details;
    }
    setState(() {
      _routines = rutinas;
    });
  }

  Future<void> _deleteExercise(int exerciseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _exerciseService.deleteExercise(exerciseId);
        await _loadExercises();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ejercicio eliminado correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar ejercicio: $e')),
          );
        }
      }
    }
  }

  Future<void> _showCreateExerciseDialog() async {
    final nombreController = TextEditingController();
    final descripcionController = TextEditingController();
    ExerciseType selectedType = ExerciseType.fuerza;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Crear Ejercicio"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseType>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: ExerciseType.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(_getExerciseTypeName(tipo)),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Tipo de ejercicio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (nombreController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un nombre')),
                );
                return;
              }
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

  String _getExerciseTypeName(ExerciseType type) {
    switch (type) {
      case ExerciseType.fuerza:
        return 'Fuerza';
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.intenso:
        return 'Intenso';
      default:
        return type.name;
    }
  }

  Future<void> _showEditExerciseDialog(Exercise exercise) async {
    final nombreController = TextEditingController(text: exercise.nombre);
    final descripcionController = TextEditingController(text: exercise.descripcion ?? '');
    ExerciseType selectedType = exercise.tipo;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Ejercicio"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExerciseType>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                items: ExerciseType.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(_getExerciseTypeName(tipo)),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Tipo de ejercicio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (nombreController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor ingresa un nombre')),
                );
                return;
              }
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

    for (var ejercicio in ejerciciosEnRutina) {
      final eSel = EjercicioSeleccionadoService(ejercicio);
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
                  decoration: const InputDecoration(
                    labelText: 'Nombre rutina',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Exercise>(
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
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar ejercicio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                const SizedBox(height: 16),
                ...ejerciciosSeleccionados.map((eSel) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  eSel.ejercicio.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                            const Divider(),
                            TextField(
                              controller: eSel.seriesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Series',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: eSel.repeticionesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Repeticiones',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: eSel.duracionController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Duración (segundos)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final nombre = nombreController.text.trim();

                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Debes ingresar un nombre para la rutina')),
                  );
                  return;
                }

                try {
                  await _routineService.updateRoutine(routine.id, nombre);
                  await _routineService.removeAllExercisesFromRoutine(routine.id);

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
                  decoration: const InputDecoration(
                    labelText: 'Nombre rutina',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Exercise>(
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
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar ejercicio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                const SizedBox(height: 16),
                ...ejerciciosSeleccionados.map((eSel) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  eSel.ejercicio.nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                            const Divider(),
                            TextField(
                              controller: eSel.seriesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Series',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: eSel.repeticionesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Repeticiones',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: eSel.duracionController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Duración (segundos)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
            onPressed: () => context.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
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
      appBar: AppBar(
        title: const Text('Rutinas y Ejercicios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Rutinas'),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildExercisesList() {
    return _exercises.isEmpty
        ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay ejercicios', style: TextStyle(fontSize: 18)),
        ],
      ),
    )
        : ListView.builder(
      itemCount: _exercises.length,
      itemBuilder: (context, index) {
        final ejercicio = _exercises[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              ejercicio.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  _getExerciseTypeName(ejercicio.tipo),
                  style: TextStyle(
                    color: _getTypeColor(ejercicio.tipo),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ejercicio.descripcion != null && ejercicio.descripcion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      ejercicio.descripcion!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
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
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: Text('¿Eliminar ejercicio "${ejercicio.nombre}"?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext, rootNavigator: true).pop(false);
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext, rootNavigator: true).pop(true);
                            },
                            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      try {
                        await _exerciseService.deleteExercise(ejercicio.id);
                        await _loadExercises();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Ejercicio eliminado correctamente')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar ejercicio: $e')),
                          );
                        }
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

  Color _getTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.fuerza:
        return Colors.blue;
      case ExerciseType.cardio:
        return Colors.green;
      case ExerciseType.intenso:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRoutinesList() {
    return _routines.isEmpty
        ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No hay rutinas', style: TextStyle(fontSize: 18)),
        ],
      ),
    )
        : ListView.builder(
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        final routine = _routines[index];
        final exercisesDetails = _routineExercisesDetails[routine.id] ?? [];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              ExpansionTile(
                title: Text(
                  routine.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                children: [
                  if (exercisesDetails.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          Text(
                            'Ejercicios:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...exercisesDetails.map((detail) {
                            final exercise = Exercise.fromMap(detail['ejercicio']);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.fitness_center, size: 16, color: _getTypeColor(exercise.tipo)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.nombre,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                          Text(
                                            '${_getExerciseTypeName(exercise.tipo)}',
                                            style: TextStyle(
                                              color: _getTypeColor(exercise.tipo),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            'Series: ${detail['series']}, Repeticiones: ${detail['repeticiones']}, Duración: ${detail['duracion'] ?? 0} segundos',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context).colorScheme.secondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  if (exercisesDetails.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'No hay ejercicios en esta rutina',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
