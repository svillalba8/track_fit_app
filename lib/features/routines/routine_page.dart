import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
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

// Página que muestra y gestiona ejercicios y rutinas
class RoutinePage extends StatefulWidget {
  const RoutinePage({super.key});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  // Servicios para operaciones CRUD de ejercicios y rutinas
  final ExerciseService _exerciseService = ExerciseService();
  final RoutineService _routineService = RoutineService();

  List<Exercise> _exercises = [];
  List<Routine> _routines = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos al crear el widget
    _fetchData();
  }

  /// Obtiene ejercicios y rutinas desde los servicios, maneja estados y errores.
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
      if (!mounted) return;
      showErrorSnackBar(context, 'Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Elimina un ejercicio y refresca la lista mostrando snackbars según el resultado.
  Future<void> _deleteExercise(Exercise exercise) async {
    setState(() => _isLoading = true);
    try {
      await _exerciseService.deleteExercise(exercise.id);
      await _fetchData();
      if (!mounted) return;
      showNeutralSnackBar(context, 'Ejercicio eliminado');
    } catch (e) {
      showErrorSnackBar(context, 'Error al eliminar ejercicio: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar un ejercicio.
  Future<void> _confirmDeleteExercise(Exercise exercise) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Confirmar eliminación',
              style: theme.textTheme.titleMedium,
            ),
            content: Text(
              '¿Quieres eliminar el ejercicio "${exercise.nombre}"?',
              style: theme.textTheme.bodyMedium,
            ),
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

  /// Elimina un ejercicio y refresca la lista mostrando snackbars según el resultado.
  Future<void> _deleteRoutine(Routine routine) async {
    setState(() => _isLoading = true);
    try {
      await _routineService.deleteRoutine(routine.id);
      await _fetchData();
      if (!mounted) return;
      showNeutralSnackBar(context, 'Rutina eliminada');
    } catch (e) {
      showErrorSnackBar(context, 'Error al eliminar rutina: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar una rutina.
  Future<void> _confirmDeleteRoutine(Routine routine) async {
    final actualTheme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Confirmar eliminación',
              style: actualTheme.textTheme.titleMedium,
            ),
            content: Text(
              '¿Quieres eliminar la rutina "${routine.nombre}"?',
              style: actualTheme.textTheme.bodyMedium,
            ),
            actions: [
              CustomButton(
                text: 'Cancelar',
                actualTheme: actualTheme,
                onPressed: () => Navigator.of(ctx).pop(false),
              ),
              CustomButton(
                text: 'Eliminar',
                actualTheme: actualTheme,
                onPressed: () => Navigator.of(ctx).pop(true),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await _deleteRoutine(routine);
    }
  }

  /// Abre un BottomSheet con los ejercicios de una rutina y permite iniciar la sesión.
  void _showRoutineDetails(Routine routine) async {
    setState(() => _isLoading = true);
    final ThemeData actualTheme = Theme.of(context);
    try {
      final exercisesData = await _routineService.getExercisesByRoutine(
        routine.id,
      );
      setState(() => _isLoading = false);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder:
            (ctx) => Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ejercicios de "${routine.nombre}"',
                      style: actualTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          exercisesData.isEmpty
                              ? Center(
                                child: Text(
                                  'No hay ejercicios asignados.',
                                  style: actualTheme.textTheme.bodyMedium,
                                ),
                              )
                              : ListView.separated(
                                itemCount: exercisesData.length,
                                separatorBuilder:
                                    (_, __) => Divider(
                                      color: actualTheme.colorScheme.outline,
                                    ),
                                itemBuilder: (context, index) {
                                  final item = exercisesData[index];
                                  final ejercicio = item['ejercicio'];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 12,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: actualTheme
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.15),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: actualTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color:
                                                  actualTheme
                                                      .colorScheme
                                                      .primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    title: Text(
                                      ejercicio['nombre'],
                                      style: actualTheme.textTheme.titleMedium,
                                    ),
                                    subtitle: Text(
                                      'Series: ${item['series']} · Reps: ${item['repeticiones']} · Duración: ${item['duracion']}s',
                                      style: actualTheme.textTheme.bodySmall,
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Empezar rutina',
                      actualTheme: actualTheme,
                      onPressed: () {
                        if (exercisesData.isEmpty) {
                          showNeutralSnackBar(
                            context,
                            'No hay ejercicios para esta rutina',
                          );
                          return;
                        }
                        context.pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => WorkoutSessionPage(
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
      showErrorSnackBar(context, 'Error al obtener ejercicios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas y Ejercicios'),
        centerTitle: true,
        backgroundColor: actualTheme.colorScheme.primary,
        foregroundColor: actualTheme.colorScheme.onPrimary,
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
                  itemBuilder:
                      (e) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: actualTheme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            e.nombre,
                            style: actualTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            e.tipo.name.toUpperCase(),
                            style: actualTheme.textTheme.bodySmall?.copyWith(
                              letterSpacing: 1,
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              CustomIconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                actualTheme: actualTheme,
                                onPressed:
                                    () => showExerciseForm(
                                      context,
                                      _exerciseService,
                                      _fetchData,
                                      exercise: e,
                                    ),
                              ),
                              CustomIconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: actualTheme.colorScheme.error,
                                ),
                                actualTheme: actualTheme,
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
                  actualTheme: actualTheme,
                  onPressed:
                      () => showExerciseForm(
                        context,
                        _exerciseService,
                        _fetchData,
                      ),
                ),
                const SizedBox(height: 32),
                SectionCard<Routine>(
                  title: 'Rutinas',
                  items: _routines,
                  itemBuilder:
                      (r) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: actualTheme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          title: Text(
                            r.nombre,
                            style: actualTheme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () => _showRoutineDetails(r),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              CustomIconButton(
                                icon: const Icon(Icons.add),
                                actualTheme: actualTheme,
                                onPressed:
                                    () => showAddExerciseToRoutineForm(
                                      context,
                                      r,
                                      _exerciseService,
                                      _routineService,
                                      _fetchData,
                                    ),
                              ),
                              CustomIconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                actualTheme: actualTheme,
                                onPressed:
                                    () => showRoutineForm(
                                      context,
                                      _routineService,
                                      _fetchData,
                                      routine: r,
                                    ),
                              ),
                              CustomIconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: actualTheme.colorScheme.error,
                                ),
                                actualTheme: actualTheme,
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
                  actualTheme: actualTheme,
                  onPressed:
                      () =>
                          showRoutineForm(context, _routineService, _fetchData),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ),
        ],
      ),
    );
  }
}
