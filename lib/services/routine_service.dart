import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<Routine?> createRoutine(String nombre) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      final response = await _client.from('rutina').insert({
        'nombre': nombre,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      return Routine.fromMap(response);
    } catch (e) {
      print('Error creating routine: $e');
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
      print('Error fetching routines: $e');
      return [];
    }
  }

  Future<void> updateRoutine(int routineId, String newName) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _client.from('rutina').update({'nombre': newName}).eq('id', routineId).eq('user_id', userId);
    } catch (e) {
      print('Error updating routine: $e');
      rethrow;
    }
  }

  Future<void> deleteRoutine(int routineId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _deleteFromRelation(routineId: routineId);
      await _client.from('rutina').delete().eq('id', routineId).eq('user_id', userId);
    } catch (e) {
      print('Error deleting routine: $e');
      rethrow;
    }
  }

  Future<List<Exercise>> getExercisesForRoutine(int routineId) async {
    final userId = _userId;
    if (userId == null) return [];
    try {
      final data = await _client
          .from('ejercicio_rufina')
          .select('''
            id_ejercicio, 
            ejercicio:ejercicio(id, nombre, tipo, descripcion)
          ''')
          .eq('id_rufina', routineId);
      return (data as List).map((e) => Exercise.fromMap(e['ejercicio'])).toList();
    } catch (e) {
      print('Error fetching routine exercises: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRoutineExercisesDetails(int routineId) async {
    final userId = _userId;
    if (userId == null) return [];
    try {
      final data = await _client
          .from('ejercicio_rufina')
          .select('''
            series, 
            repeticiones, 
            duzacion,  // Corrected column name
            ejercicio:ejercicio_id(id, nombre, tipo, descripcion)
          ''')
          .eq('id_rufina', routineId);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching exercise details: $e');
      return [];
    }
  }

  Future<void> addExerciseToRoutine({
    required int rutinaId,
    required int ejercicioId,
    required int series,
    required int repeticiones,
    double? duracion,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    final routine = await _client
        .from('rutina')
        .select()
        .eq('id', rutinaId)
        .eq('user_id', userId)
        .maybeSingle();
    if (routine == null) throw Exception('Routine not found or does not belong to user');

    final exercise = await _client
        .from('ejercicio')
        .select()
        .eq('id', ejercicioId)
        .eq('user_id', userId)
        .maybeSingle();
    if (exercise == null) throw Exception('Exercise not found or does not belong to user');

    try {
      await _client.from('ejercicio_rufina').insert({
        'id_rufina': rutinaId,
        'id_ejercicio': ejercicioId,
        'series': series,
        'repeticiones': repeticiones,
        'duzacion': duracion,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding exercise to routine: $e');
      rethrow;
    }
  }

  Future<void> removeAllExercisesFromRoutine(int routineId) async {
    await _deleteFromRelation(routineId: routineId);
  }

  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _client
          .from('ejercicio_rutina')
          .delete()
          .eq('id_rutina', routineId)
          .eq('id_ejercicio', exerciseId);
    } catch (e) {
      print('Error removing exercise from routine: $e');
      rethrow;
    }
  }

  Future<void> _deleteFromRelation({required int routineId}) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    final routine = await _client
        .from('rutina')
        .select()
        .eq('id', routineId)
        .eq('user_id', userId)
        .maybeSingle();
    if (routine == null) throw Exception('Routine not found or does not belong to user');

    await _client.from('ejercicio_rutina').delete().eq('id_rutina', routineId);
  }
}
