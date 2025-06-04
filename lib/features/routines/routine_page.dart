import 'package:flutter/material.dart';
import '../../core/enums/exercise_type.dart';
import '../../models/exercise_model.dart';
import '../../models/routine_model.dart';
import '../../services/exercise_service.dart';
import '../../services/routine_service.dart';
import '../../widgets/routines_page_widgets/add_exercise_to_routine_form.dart';
import '../../widgets/routines_page_widgets/exercise_form.dart';
import '../../widgets/routines_page_widgets/routine_form.dart';
import '../../widgets/routines_page_widgets/section_card.dart';
import 'workout_session_page.dart';
import '../../widgets/custom_button.dart';

class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  final ExerciseService _exerciseService = ExerciseService();
  final RoutineService _routineService = RoutineService();

  List<Exercise> _exercises = [];
  List<Routine> _routines = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final exercises = await _exerciseService.getExercises();
      final routines = await _routineService.getRoutines();
      setState(() {
        _exercises = exercises;
        _routines = routines;
      });
    } catch (e) {
      _showSnackBar('Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteExercise(Exercise exercise) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Quieres eliminar el ejercicio "${exercise.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await _deleteExercise(exercise);
    }
  }

  Future<void> _deleteExercise(Exercise exercise) async {
    setState(() => _isLoading = true);
    try {
      await _exerciseService.deleteExercise(exercise.id);
      await _fetchData();
      _showSnackBar('Ejercicio eliminado');
    } catch (e) {
      _showSnackBar('Error al eliminar ejercicio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDeleteRoutine(Routine routine) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Quieres eliminar la rutina "${routine.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await _deleteRoutine(routine);
    }
  }

  Future<void> _deleteRoutine(Routine routine) async {
    setState(() => _isLoading = true);
    try {
      await _routineService.deleteRoutine(routine.id);
      await _fetchData();
      _showSnackBar('Rutina eliminada');
    } catch (e) {
      _showSnackBar('Error al eliminar rutina: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _showRoutineDetails(Routine routine) async {
    setState(() => _isLoading = true);
    try {
      final exercisesData = await _routineService.getExercisesByRoutine(routine.id);
      setState(() => _isLoading = false);

      final theme = Theme.of(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Ejercicios de "${routine.nombre}"',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: exercisesData.isEmpty
                      ? const Center(child: Text('No hay ejercicios asignados.'))
                      : ListView.separated(
                    itemCount: exercisesData.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = exercisesData[index];
                      final ejercicio = item['ejercicio'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            (index + 1).toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(ejercicio['nombre']),
                        subtitle: Text(
                          'Series: ${item['series']}, Reps: ${item['repeticiones']}, Duración: ${item['duracion']}s',
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Empezar rutina',
                  onPressed: () {
                    if (exercisesData.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No hay ejercicios para esta rutina')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutSessionPage(
                          routineName: routine.nombre,
                          exercises: exercisesData,
                        ),
                      ),
                    );
                  },
                  actualTheme: Theme.of(context),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error al obtener ejercicios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas y Ejercicios'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 4,
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                SectionCard<Exercise>(
                  title: 'Ejercicios',
                  items: _exercises,
                  itemBuilder: (e) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(e.nombre, style: theme.textTheme.titleMedium),
                        subtitle: Text(e.tipo.name, style: theme.textTheme.bodySmall),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Editar ejercicio',
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => showExerciseForm(context, _exerciseService, _fetchData, exercise: e),
                            ),
                            IconButton(
                              tooltip: 'Eliminar ejercicio',
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDeleteExercise(e),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  // Eliminamos onAdd para no mostrar el botón aparte
                ),
                // Botón integrado al final de la lista de ejercicios
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir nuevo ejercicio'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showExerciseForm(context, _exerciseService, _fetchData),
                  ),
                ),

                const SizedBox(height: 24),

                SectionCard<Routine>(
                  title: 'Rutinas',
                  items: _routines,
                  itemBuilder: (r) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(r.nombre, style: theme.textTheme.titleMedium),
                        onTap: () => _showRoutineDetails(r),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Agregar ejercicio',
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () => showAddExerciseToRoutineForm(context, r, _exerciseService, _routineService, _fetchData),
                            ),
                            IconButton(
                              tooltip: 'Editar rutina',
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => showRoutineForm(context, _routineService, _fetchData, routine: r),
                            ),
                            IconButton(
                              tooltip: 'Eliminar rutina',
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _confirmDeleteRoutine(r),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  // Eliminamos onAdd para no mostrar el botón aparte
                ),
                // Botón integrado al final de la lista de rutinas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Añadir nueva rutina'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => showRoutineForm(context, _routineService, _fetchData),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
