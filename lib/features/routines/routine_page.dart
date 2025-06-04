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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final exercises = await _exerciseService.getExercises();
    final routines = await _routineService.getRoutines();
    setState(() {
      _exercises = exercises;
      _routines = routines;
    });
  }

  void _showRoutineDetails(Routine routine) async {
    final exercisesData = await _routineService.getExercisesByRoutine(routine.id);
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
                    : ListView.builder(
                  itemCount: exercisesData.length,
                  itemBuilder: (context, index) {
                    final item = exercisesData[index];
                    final ejercicio = item['ejercicio'];
                    return ListTile(
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
                text: 'Empezar',
                onPressed: exercisesData.isEmpty ? () {} : () {
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
              )

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas y Ejercicios'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          children: [
            SectionCard<Exercise>(
              title: 'Ejercicios',
              items: _exercises,
              itemBuilder: (e) => ListTile(
                title: Text(e.nombre),
                subtitle: Text(e.tipo.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showExerciseForm(
                        context,
                        _exerciseService,
                        _fetchData,
                        exercise: e,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await _exerciseService.deleteExercise(e.id);
                        _fetchData();
                      },
                    ),
                  ],
                ),
              ),
              onAdd: () => showExerciseForm(context, _exerciseService, _fetchData),
            ),
            SectionCard<Routine>(
              title: 'Rutinas',
              items: _routines,
              itemBuilder: (r) => ListTile(
                title: Text(r.nombre),
                onTap: () => _showRoutineDetails(r),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => showAddExerciseToRoutineForm(
                        context,
                        r,
                        _exerciseService,
                        _routineService,
                        _fetchData,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showRoutineForm(
                        context,
                        _routineService,
                        _fetchData,
                        routine: r,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await _routineService.deleteRoutine(r.id);
                        _fetchData();
                      },
                    ),
                  ],
                ),
              ),
              onAdd: () => showRoutineForm(context, _routineService, _fetchData),
            ),
          ],
        ),
      ),
    );
  }
}
