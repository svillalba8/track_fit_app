import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
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
  List<RoutineWithExercises> _routines = [];

  // 1. INIT & LOAD DATA
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final ejercicios = await _exerciseService.getExercises();
    final rutinas = await _routineService.getRoutinesWithExercises();
    setState(() {
      _exercises = ejercicios;
      _routines = rutinas;
    });
  }

  // 2. CREACIÓN DE EJERCICIOS Y RUTINAS
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
              isExpanded: true,
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
              await _loadData();
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
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rutina creada con ejercicios')),
                  );
                  await _loadData();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ejercicio) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ejercicio.nombre,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${ejercicio.tipo.name.toUpperCase()} • ${ejercicio.descripcion ?? "Sin descripción"}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRoutineCard(RoutineWithExercises rutinaConEjercicios) {
    final rutina = rutinaConEjercicios.rutina;
    final ejercicios = rutinaConEjercicios.ejercicios;

    return Card(
      color: Colors.grey.shade100,
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: const Icon(Icons.list_alt, color: Colors.green),
        title: Text(rutina.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("🏋️ Ejercicios asignados: ${ejercicios.length}"),
                const Divider(thickness: 1.2),
                ...ejercicios.map((e) {
                  return ListTile(
                    title: Text(e.exercise.nombre),
                    subtitle: Text(
                      'Series: ${e.series}  •  Repeticiones: ${e.repeticiones ?? '-'}  •  Duración: ${e.duracion?.toStringAsFixed(0) ?? '-'}s',
                    ),
                    leading: const Icon(Icons.arrow_right),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. UTILIDAD
  String _formatFecha(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rutinas y Ejercicios',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        foregroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFFF6F8FA),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showCreateExerciseDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Ejercicio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _showCreateRoutineDialog,
                        icon: const Icon(Icons.playlist_add),
                        label: const Text('Rutina'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text(
                  '🏋️ Ejercicios',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._exercises.map(_buildExerciseCard),

                const SizedBox(height: 24),
                const Text(
                  '📋 Rutinas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._routines.map(_buildRoutineCard),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
