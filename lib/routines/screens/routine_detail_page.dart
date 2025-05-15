import 'package:flutter/material.dart';
import '../enums/exercise_type.dart';
import '../models/routine.dart';
import '../models/exercise.dart';
import '../models/ejercicio_rutina.dart';
import '../services/routine_service.dart';

class RoutineDetailPage extends StatefulWidget {
  final Routine routine;

  const RoutineDetailPage({Key? key, required this.routine}) : super(key: key);

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final RoutineService _routineService = RoutineService();
  List<Map<String, dynamic>> _ejercicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEjercicios();
  }

  Future<void> _loadEjercicios() async {
    setState(() => _isLoading = true);
    try {
      final ejercicios = await _routineService.getEjerciciosForRutina(widget.routine.id);
      setState(() {
        _ejercicios = ejercicios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar: ${e.toString()}')),
      );
    }
  }

  Future<void> _editExerciseDetails(int index) async {
    final ejercicio = _ejercicios[index]['ejercicio'] as Exercise;
    final isCardio = ejercicio.tipo == ExerciseType.cardio;

    final seriesCtrl = TextEditingController(
        text: _ejercicios[index]['series'].toString());
    final repeticionesCtrl = TextEditingController(
        text: isCardio ? '0' : _ejercicios[index]['repeticiones'].toString());
    final duracionCtrl = TextEditingController(
        text: _ejercicios[index]['duracion']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${ejercicio.nombre}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: seriesCtrl,
                decoration: const InputDecoration(labelText: 'Series'),
                keyboardType: TextInputType.number,
              ),
              if (!isCardio)
                TextField(
                  controller: repeticionesCtrl,
                  decoration: const InputDecoration(labelText: 'Repeticiones'),
                  keyboardType: TextInputType.number,
                ),
              if (isCardio)
                Column(
                  children: [
                    TextField(
                      controller: duracionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Duración (minutos)',
                        hintText: 'Ej: 30',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const Text(
                      'Introduce minutos enteros',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
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
            onPressed: () async {
              try {
                final series = int.tryParse(seriesCtrl.text) ?? 3;
                final repeticiones = isCardio ? 0 : int.tryParse(repeticionesCtrl.text) ?? 10;
                int? duracion;

                if (isCardio && duracionCtrl.text.isNotEmpty) {
                  // Convertir a double primero y luego a int
                  duracion = double.tryParse(duracionCtrl.text)?.round();
                }

                await _routineService.addExerciseToRutina(
                  rutinaId: widget.routine.id,
                  ejercicioId: ejercicio.id,
                  series: series,
                  repeticiones: repeticiones,
                  duracion: duracion?.toDouble(), // Convertimos a double para el método
                );

                Navigator.pop(context);
                await _loadEjercicios();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  String _getExerciseDetails(Map<String, dynamic> ejercicio) {
    final series = ejercicio['series'] ?? 0;
    final repeticiones = ejercicio['repeticiones'] ?? 0;
    final duracion = ejercicio['duracion'] as int?;
    final isCardio = (ejercicio['ejercicio'] as Exercise).tipo == ExerciseType.cardio;

    if (isCardio) {
      return 'Series: $series${duracion != null ? ' | Duración: ${duracion}min' : ''}';
    } else {
      return 'Series: $series | Reps: $repeticiones';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.nombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEjercicios,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ejercicios.isEmpty
          ? const Center(child: Text('No hay ejercicios en esta rutina'))
          : ListView.builder(
        itemCount: _ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = _ejercicios[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text((ejercicio['ejercicio'] as Exercise).nombre),
              subtitle: Text(_getExerciseDetails(ejercicio)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editExerciseDetails(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete((ejercicio['ejercicio'] as Exercise).id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(int ejercicioId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: const Text('¿Seguro que deseas eliminar este ejercicio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _routineService.deleteExerciseFromRutina(
            widget.routine.id,
            ejercicioId
        );
        await _loadEjercicios();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: ${e.toString()}')),
        );
      }
    }
  }
}