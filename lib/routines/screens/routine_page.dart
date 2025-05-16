import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../models/exercise.dart';
import '../enums/exercise_type.dart';
import '../services/ejercicio_seleccionado_service.dart';
import '../services/exercise_service.dart';
import '../services/routine_service.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final _exerciseService = ExerciseService();
  final _routineService = RoutineService();
  List<Exercise> _exercises = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final ejercicios = await _exerciseService.getExercises();
    setState(() {
      _exercises = ejercicios;
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

  void _showCreateRoutineDialog() async {
    final nombreController = TextEditingController();
    final ejerciciosDisponibles = await _routineService.getExercises();

    if (ejerciciosDisponibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Primero debes crear al menos un ejercicio.')),
      );
      return;
    }

    final ejerciciosSeleccionados = <EjercicioSeleccionadoService>[];
    Exercise? selectedExercise = ejerciciosDisponibles.first;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Crear rutina'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(labelText: 'Nombre rutina'),
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
                  child: Text('Añadir ejercicio'),
                ),
                ...ejerciciosSeleccionados.map((eSel) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text(eSel.ejercicio.nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                        TextField(
                          controller: eSel.seriesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Series'),
                        ),
                        TextField(
                          controller: eSel.repeticionesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Repeticiones'),
                        ),
                        TextField(
                          controller: eSel.duracionController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Duración (segundos)'),
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
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final nombre = nombreController.text.trim();

                  if (nombre.isEmpty || ejerciciosSeleccionados.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debes ingresar un nombre y al menos un ejercicio')),
                    );
                    return;
                  }

                  final nuevaRutina = await _routineService.createRoutine(nombre);

                  for (var eSel in ejerciciosSeleccionados) {
                    final series = int.tryParse(eSel.seriesController.text.trim()) ?? 0;
                    final repes = int.tryParse(eSel.repeticionesController.text.trim()) ?? 0;
                    final duracion = int.tryParse(eSel.duracionController.text.trim());

                    await _routineService.addExerciseToRutina(
                      rutinaId: nuevaRutina!.id,
                      ejercicioId: eSel.ejercicio.id,
                      series: series,
                      repeticiones: repes,
                      duracion: duracion?.toDouble(),
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rutina creada con ejercicios')));
                  }
                } catch (e) {
                  print('Error al crear rutina: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al crear rutina')));
                }
              },
              child: Text('Guardar'),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: 'Crear Ejercicio',
              onPressed: _showCreateExerciseDialog,
              colorTheme: Colors.blue,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Crear Rutina',
              onPressed: _showCreateRoutineDialog,
              colorTheme: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
