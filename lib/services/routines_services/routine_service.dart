import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/exercise_model.dart';
import '../models/exercise_with_details_model.dart';
import '../models/routine_model.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Crear rutina
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

  // Obtener rutinas del usuario
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

  // Actualizar nombre de rutina
  Future<void> updateRoutine(int routineId, String newName) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _client
          .from('rutina')
          .update({'nombre': newName})
          .eq('id', routineId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error updating routine: $e');
      rethrow;
    }
  }

  // Eliminar rutina y sus relaciones
  Future<void> deleteRoutine(int routineId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');
    try {
      await _deleteFromRelation(routineId: routineId);
      await _client
          .from('rutina')
          .delete()
          .eq('id', routineId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error deleting routine: $e');
      rethrow;
    }
  }

  // Agregar ejercicio a rutina
  Future<void> addExerciseToRoutine({
    required int routineId,
    required int exerciseId,
    required int series,
    required int reps,
    required int duration,
  }) async {
    try {
      await _client.from('ejercicio_rutina').insert({
        'id_rutina': routineId,
        'id_ejercicio': exerciseId,
        'series': series,
        'repeticiones': reps,
        'duracion': duration,
      });
    } catch (e) {
      print('Error adding exercise to routine: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getExercisesByRoutine(int routineId) async {
    try {
      final data = await _client
          .from('ejercicio_rutina')
          .select('series, repeticiones, duracion, ejercicio(id, nombre, tipo, descripcion)')
          .eq('id_rutina', routineId);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching exercises by routine: $e');
      return [];
    }
  }

  // Obtener ejercicios con detalles de una rutina (modelo)
  Future<List<ExerciseWithDetails>> getExercisesForRoutine(int routineId) async {
    try {
      final response = await _client
          .from('ejercicio_rutina')
          .select('*, ejercicio:id_ejercicio(id, nombre, tipo, descripcion)')
          .eq('id_rutina', routineId);

      return (response as List)
          .map((e) => ExerciseWithDetails.fromMap(e))
          .toList();
    } catch (e) {
      print('Error fetching exercises for routine: $e');
      return [];
    }
  }

  // Eliminar todos los ejercicios de una rutina
  Future<void> removeAllExercisesFromRoutine(int routineId) async {
    await _deleteFromRelation(routineId: routineId);
  }

  // Eliminar un solo ejercicio de una rutina
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId) async {
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

  // Internamente borra todos los ejercicios relacionados a la rutina
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
