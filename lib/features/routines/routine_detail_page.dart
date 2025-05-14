import 'package:flutter/material.dart';
import '../../models/routine_model.dart';
import '../../models/exercise_model.dart';
import '../../services/routine_service.dart';

class RoutineDetailPage extends StatefulWidget {
  final Routine routine;

  const RoutineDetailPage({Key? key, required this.routine}) : super(key: key);

  @override
  State<RoutineDetailPage> createState() => _RoutineDetailPageState();
}

class _RoutineDetailPageState extends State<RoutineDetailPage> {
  final RoutineService _routineService = RoutineService();
  List<Map<String, dynamic>> _ejercicios = [];

  @override
  void initState() {
    super.initState();
    _loadEjercicios();
  }

  Future<void> _loadEjercicios() async {
    final ejercicios = await _routineService.getEjerciciosForRutina(
      widget.routine.id,
    );
    setState(() {
      _ejercicios = ejercicios;
    });
  }

  Future<void> _confirmDelete(int ejercicioId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar ejercicio'),
            content: const Text(
              '¿Seguro que deseas eliminar este ejercicio de la rutina?',
            ),
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
      await _routineService.deleteExerciseFromRutina(
        widget.routine.id,
        ejercicioId,
      );
      _loadEjercicios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rutina: ${widget.routine.nombre}')),
      body:
          _ejercicios.isEmpty
              ? const Center(child: Text('No hay ejercicios en esta rutina.'))
              : ListView.builder(
                itemCount: _ejercicios.length,
                itemBuilder: (context, index) {
                  final ejercicio = _ejercicios[index]['ejercicio'] as Exercise;
                  final series = _ejercicios[index]['series'] ?? 0;
                  final repeticiones = _ejercicios[index]['repeticiones'] ?? 0;
                  final duracion = _ejercicios[index]['duracion'];

                  return ListTile(
                    title: Text(ejercicio.nombre),
                    subtitle: Text(
                      'Series: $series | Reps: $repeticiones | ${duracion != null ? 'Duración: ${duracion}min' : 'Sin duración'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(ejercicio.id),
                    ),
                  );
                },
              ),
    );
  }
}
