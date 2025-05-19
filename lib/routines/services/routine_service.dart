import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/exercise_type.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/ejercicio_rutina.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<Exercise>> getExercises() async {
    final userId = _userId;
    if (userId == null) {
      print('Usuario no autenticado.');
      return [];
    }

    try {
      final data = await _client
          .from('ejercicio')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      print('Ejercicios obtenidos: ${data.length}');
      return (data as List).map((e) => Exercise.fromMap(e)).toList();
    } catch (e) {
      print('Error al obtener ejercicios: $e');
      return [];
    }
  }

  Future<void> createExercise(String nombre, ExerciseType tipo, String? descripcion) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _client.from('ejercicio').insert({
        'nombre': nombre,
        'tipo': tipo.name,
        'descripcion': descripcion,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al crear ejercicio: $e');
      rethrow;
    }
  }

  Future<void> updateExercise(int id, String nombre, ExerciseType tipo, String? descripcion) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('ejercicio')
          .update({
        'nombre': nombre,
        'tipo': tipo.name,
        'descripcion': descripcion,
      })
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al actualizar ejercicio: $e');
      rethrow;
    }
  }

  Future<void> deleteExercise(int id) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('ejercicio')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al eliminar ejercicio: $e');
      rethrow;
    }
  }

  Future<Routine?> createRoutine(String nombre) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('rutina')
          .insert({
        'nombre': nombre,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      return Routine.fromMap(response);
    } catch (e) {
      print('Error al crear rutina: $e');
      rethrow;
    }
  }

  Future<List<Routine>> getRoutines() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('rutina')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List).map((e) => Routine.fromMap(e)).toList();
    } catch (e) {
      print('Error al obtener rutinas: $e');
      return [];
    }
  }

  Future<void> addExerciseToRutina({
    required int rutinaId,
    required int ejercicioId,
    required int series,
    int? repeticiones,
    double? duracion,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      final exercise = await _client
          .from('ejercicio')
          .select()
          .eq('id', ejercicioId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Rutina no encontrada o no pertenece al usuario.');
      if (exercise == null) throw Exception('Ejercicio no encontrado o no pertenece al usuario.');

      await _client.from('ejercicio_rutina').insert({
        'id_rutina': rutinaId,
        'id_ejercicio': ejercicioId,
        'series': series,
        'repeticiones': repeticiones,
        'duracion': duracion,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al añadir ejercicio a la rutina: $e');
      rethrow;
    }
  }

  Future<List<RoutineWithExercises>> getRoutinesWithExercises() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final rutinasData = await _client
          .from('rutina')
          .select('*, ejercicio_rutina(*, ejercicio(*))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);


      List<Routine> rutinas = (rutinasData as List)
          .map((r) => Routine.fromMap(r))
          .toList();

      List<RoutineWithExercises> rutinasConEjercicios = [];

      for (var rutina in rutinas) {
        final ejerciciosRutinaData = await _client
            .from('ejercicio_rutina')
            .select()
            .eq('id_rutina', rutina.id)
            .order('created_at', ascending: true);

        List<EjercicioRutina> ejerciciosRutina = (ejerciciosRutinaData as List)
            .map((e) => EjercicioRutina.fromMap(e))
            .toList();

        List<int> ejerciciosIds = ejerciciosRutina.map((e) => e.idEjercicio).toList();

        if (ejerciciosIds.isEmpty) {
          rutinasConEjercicios.add(RoutineWithExercises(rutina: rutina, ejercicios: []));
          continue;
        }

        final ejerciciosData = await _client
            .from('ejercicio')
            .select()
            .filter('id', 'in', '(${ejerciciosIds.join(",")})')
            .order('created_at', ascending: false);

        List<Exercise> ejercicios = (ejerciciosData as List)
            .map((e) => Exercise.fromMap(e))
            .toList();

        List<ExerciseWithDetails> ejerciciosConDetalles = ejerciciosRutina.map((ejRutina) {
          final ejercicio = ejercicios.firstWhere((ex) => ex.id == ejRutina.idEjercicio);
          return ExerciseWithDetails(
            exercise: ejercicio,
            series: ejRutina.series,
            repeticiones: ejRutina.repeticiones,
            duracion: ejRutina.duracion,
          );
        }).toList();

        rutinasConEjercicios.add(
          RoutineWithExercises(
            rutina: rutina,
            ejercicios: ejerciciosConDetalles,
          ),
        );
      }

      return rutinasConEjercicios;
    } catch (e) {
      print('Error fetching routines with exercises: $e');
      return [];
    }
  }

}

class RoutineWithExercises {
  final Routine rutina;
  final List<ExerciseWithDetails> ejercicios;

  RoutineWithExercises({
    required this.rutina,
    required this.ejercicios,
  });
}

class ExerciseWithDetails {
  final Exercise exercise;
  final int series;
  final int? repeticiones;
  final double? duracion;

  ExerciseWithDetails({
    required this.exercise,
    required this.series,
    this.repeticiones,
    this.duracion,
  });
}
