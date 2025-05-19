import 'package:flutter/material.dart';
import 'package:track_fit_app/core/enums/exercise_type.dart';
import 'package:track_fit_app/features/routines/routine_detail_page.dart';
import '../../models/routine_model.dart';
import '../../models/exercise_model.dart';
import '../../services/routine_service.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({Key? key}) : super(key: key);

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final RoutineService _routineService = RoutineService();
  List<Routine> _rutinas = [];
  List<Exercise> _ejercicios = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Carga las rutinas y ejercicios desde el servicio
  Future<void> _loadData() async {
    final rutinas = await _routineService.getRoutines(); // Obtiene las rutinas
    final ejercicios =
        await _routineService.getExercises(); // Obtiene los ejercicios
    setState(() {
      _rutinas = rutinas;
      _ejercicios = ejercicios;
    });
  }

  // Muestra un diálogo para agregar un nuevo ejercicio
  Future<void> _addExerciseDialog() async {
    final nombreCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController();
    ExerciseType tipoSeleccionado = ExerciseType.cardio; // Valor inicial

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Nuevo Ejercicio'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(hintText: 'Nombre'),
                ),
                TextField(
                  controller: descripcionCtrl,
                  decoration: const InputDecoration(hintText: 'Descripción'),
                ),
                const SizedBox(height: 16),
                const Text('Selecciona un tipo de ejercicio:'),
                // Botones para elegir el tipo de ejercicio
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        tipoSeleccionado = ExerciseType.cardio;
                      },
                      child: const Text('Cardio'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        tipoSeleccionado = ExerciseType.fuerza;
                      },
                      child: const Text('Fuerza'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        tipoSeleccionado = ExerciseType.intenso;
                      },
                      child: const Text('Intenso'),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nombre = nombreCtrl.text.trim();
                  final descripcion = descripcionCtrl.text.trim();
                  if (nombre.isEmpty) return;

                  // Crear el ejercicio usando el tipo de ejercicio seleccionado
                  await _routineService.createExercise(
                    nombre,
                    tipoSeleccionado,
                    descripcion,
                  );

                  // Mostrar un mensaje de éxito usando un Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ejercicio registrado')),
                  );

                  Navigator.pop(context);
                  _loadData();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  // Muestra un diálogo para agregar una nueva rutina
  Future<void> _addRoutineDialog() async {
    final nombreCtrl = TextEditingController();
    final selectedExercises = <Exercise>{};

    await showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Nueva Rutina'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: nombreCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Nombre de la rutina',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Selecciona ejercicios:'),
                        ..._ejercicios.map((exercise) {
                          return CheckboxListTile(
                            title: Text(exercise.nombre),
                            subtitle: Text(exercise.descripcion ?? ''),
                            value: selectedExercises.contains(exercise),
                            onChanged: (val) {
                              setDialogState(() {
                                if (val == true) {
                                  selectedExercises.add(exercise);
                                } else {
                                  selectedExercises.remove(exercise);
                                }
                              });
                            },
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
                      onPressed: () async {
                        final nombre = nombreCtrl.text.trim();
                        if (nombre.isEmpty || selectedExercises.isEmpty) return;

                        // Aquí se crea la rutina con el nombre proporcionado
                        await _routineService.createRoutine(nombre);

                        // Luego, obtenemos las rutinas para encontrar la recién creada
                        final rutinas = await _routineService.getRoutines();
                        final nuevaRutina = rutinas.firstWhere(
                          (r) => r.nombre == nombre,
                        );

                        // Finalmente, se asocian los ejercicios seleccionados a la nueva rutina
                        for (var ejercicio in selectedExercises) {
                          await _routineService.addExerciseToRutina(
                            rutinaId: nuevaRutina.id,
                            ejercicioId: ejercicio.id,
                            series: 3,
                            repeticiones: 10,
                            duracion: null,
                          );
                        }

                        Navigator.pop(context);
                        _loadData();
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rutinas y Ejercicios')),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Añadir Rutina'),
                onPressed: _addRoutineDialog,
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.fitness_center),
                label: const Text('Añadir Ejercicio'),
                onPressed: _addExerciseDialog,
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _rutinas.length,
              itemBuilder: (_, index) {
                final rutina = _rutinas[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(rutina.nombre),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => RoutineDetailPage(routine: rutina),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
