import 'package:flutter/material.dart';
import 'package:track_fit_app/routines/enums/exercise_type.dart';
import 'package:track_fit_app/routines/screens/routine_detail_page.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../services/routine_service.dart';

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
    final rutinas = await _routineService.getRoutines();  // Obtiene las rutinas
    final ejercicios = await _routineService.getExercises();  // Obtiene los ejercicios
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
      builder: (_) => AlertDialog(
        title: const Text('Nuevo Ejercicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(hintText: 'Nombre')),
            TextField(controller: descripcionCtrl, decoration: const InputDecoration(hintText: 'Descripción')),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final descripcion = descripcionCtrl.text.trim();
              if (nombre.isEmpty) return;

              // Crear el ejercicio usando el tipo de ejercicio seleccionado
              await _routineService.createExercise(nombre, tipoSeleccionado, descripcion);

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
    final selectedExercises = <Exercise>[];
    final seriesControllers = <TextEditingController>[];
    final repeticionesControllers = <TextEditingController>[];
    final duracionControllers = <TextEditingController>[];

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nueva Rutina'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Nombre de la rutina',
                    labelText: 'Nombre*',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selecciona ejercicios:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._ejercicios.map((exercise) {
                  final isSelected = selectedExercises.contains(exercise);
                  final isCardio = exercise.tipo == ExerciseType.cardio;
                  final index = selectedExercises.indexOf(exercise);

                  return Column(
                    children: [
                      CheckboxListTile(
                        title: Text(exercise.nombre),
                        subtitle: Text('Tipo: ${exercise.tipo.name}'),
                        value: isSelected,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedExercises.add(exercise);
                              seriesControllers.add(TextEditingController(text: '3'));
                              repeticionesControllers.add(
                                  TextEditingController(text: isCardio ? '0' : '10'));
                              duracionControllers.add(
                                  TextEditingController(text: isCardio ? '30' : ''));
                            } else {
                              final removeIndex = selectedExercises.indexOf(exercise);
                              selectedExercises.removeAt(removeIndex);
                              seriesControllers.removeAt(removeIndex);
                              repeticionesControllers.removeAt(removeIndex);
                              duracionControllers.removeAt(removeIndex);
                            }
                          });
                        },
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: seriesControllers[index],
                                      decoration: const InputDecoration(
                                        labelText: 'Series*',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (!isCardio)
                                    Expanded(
                                      child: TextField(
                                        controller: repeticionesControllers[index],
                                        decoration: const InputDecoration(
                                          labelText: 'Repeticiones*',
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                ],
                              ),
                              if (isCardio)
                                TextField(
                                  controller: duracionControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Duración (min)*',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                    ],
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
                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El nombre es requerido')),
                  );
                  return;
                }

                if (selectedExercises.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona al menos un ejercicio')),
                  );
                  return;
                }

                try {
                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );

                  // 1. Crear la rutina
                  final nuevaRutina = await _routineService.createRoutine(nombre);

                  if (nuevaRutina == null) {
                    Navigator.pop(context); // Cerrar loading
                    throw Exception('No se pudo crear la rutina');
                  }

                  // 2. Asociar ejercicios con sus configuraciones
                  for (int i = 0; i < selectedExercises.length; i++) {
                    final exercise = selectedExercises[i];
                    final series = int.tryParse(seriesControllers[i].text) ?? 3;
                    final repeticiones = exercise.tipo == ExerciseType.cardio
                        ? 0
                        : int.tryParse(repeticionesControllers[i].text) ?? 10;
                    final duracion = exercise.tipo == ExerciseType.cardio
                        ? double.tryParse(duracionControllers[i].text)?.round()
                        : null;

                    await _routineService.addExerciseToRutina(
                      rutinaId: nuevaRutina.id,
                      ejercicioId: exercise.id,
                      series: series,
                      repeticiones: repeticiones,
                      duracion: duracion?.toDouble(),
                    );
                  }

                  // Cerrar diálogos y actualizar lista
                  Navigator.pop(context); // Cerrar loading
                  Navigator.pop(context); // Cerrar diálogo
                  _loadData();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rutina creada exitosamente')),
                  );
                } catch (e) {
                  Navigator.pop(context); // Cerrar loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al crear rutina: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Guardar Rutina'),
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
                          builder: (context) => RoutineDetailPage(routine: rutina),
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
