import 'package:flutter/material.dart';
import 'package:track_fit_app/features/routines/services/exercise_service.dart';
import 'package:track_fit_app/features/routines/services/routine_service.dart';
import 'package:track_fit_app/features/routines/widgets/add_exercise_to_routine_form.dart';
import 'package:track_fit_app/features/routines/widgets/exercise_form.dart';
import 'package:track_fit_app/features/routines/widgets/routine_form.dart';
import 'package:track_fit_app/features/routines/widgets/section_card.dart';
import '../../core/enums/exercise_type.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_icon_button.dart';
import 'models/exercise_model.dart';
import 'models/routine_model.dart';
import 'secondary_pages/workout_session_page.dart';

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
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación', style: theme.textTheme.titleMedium),
        content: Text('¿Quieres eliminar el ejercicio "${exercise.nombre}"?', style: theme.textTheme.bodyMedium),
        actions: [
          CustomButton(
            text: 'Cancelar',
            actualTheme: theme,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CustomButton(
            text: 'Eliminar',
            actualTheme: theme,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
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
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmar eliminación', style: theme.textTheme.titleMedium),
        content: Text('¿Quieres eliminar la rutina "${routine.nombre}"?', style: theme.textTheme.bodyMedium),
        actions: [
          CustomButton(
            text: 'Cancelar',
            actualTheme: theme,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CustomButton(
            text: 'Eliminar',
            actualTheme: theme,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
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
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: exercisesData.isEmpty
                      ? Center(child: Text('No hay ejercicios asignados.', style: theme.textTheme.bodyMedium))
                      : ListView.separated(
                    itemCount: exercisesData.length,
                    separatorBuilder: (_, __) => Divider(color: theme.colorScheme.outline),
                    itemBuilder: (context, index) {
                      final item = exercisesData[index];
                      final ejercicio = item['ejercicio'];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                          child: Text(
                            (index + 1).toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        title: Text(ejercicio['nombre'], style: theme.textTheme.titleMedium),
                        subtitle: Text(
                          'Series: ${item['series']} · Reps: ${item['repeticiones']} · Duración: ${item['duracion']}s',
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Empezar rutina',
                  actualTheme: theme,
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchData,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              children: [
                SectionCard<Exercise>(
                  title: 'Ejercicios',
                  items: _exercises,
                  itemBuilder: (e) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      title: Text(e.nombre, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: Text(e.tipo.name.toUpperCase(), style: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1)),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          CustomIconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            actualTheme: theme,
                            onPressed: () => showExerciseForm(context, _exerciseService, _fetchData, exercise: e),
                          ),
                          CustomIconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            actualTheme: theme,
                            onPressed: () => _confirmDeleteExercise(e),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Añadir nuevo ejercicio',
                  actualTheme: theme,
                  onPressed: () => showExerciseForm(context, _exerciseService, _fetchData),
                ),
                const SizedBox(height: 32),
                SectionCard<Routine>(
                  title: 'Rutinas',
                  items: _routines,
                  itemBuilder: (r) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    shadowColor: theme.colorScheme.primary.withOpacity(0.15),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      title: Text(r.nombre, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      onTap: () => _showRoutineDetails(r),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          CustomIconButton(
                            icon: const Icon(Icons.add),
                            actualTheme: theme,
                            onPressed: () => showAddExerciseToRoutineForm(context, r, _exerciseService, _routineService, _fetchData),
                          ),
                          CustomIconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            actualTheme: theme,
                            onPressed: () => showRoutineForm(context, _routineService, _fetchData, routine: r),
                          ),
                          CustomIconButton(
                            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                            actualTheme: theme,
                            onPressed: () => _confirmDeleteRoutine(r),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Añadir nueva rutina',
                  actualTheme: theme,
                  onPressed: () => showRoutineForm(context, _routineService, _fetchData),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
            ),
        ],
      ),
    );
  }
}
