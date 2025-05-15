import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/exercise_type.dart';
import '../models/exercise.dart';
import '../models/routine.dart';
import '../models/ejercicio_rutina.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  // Obtener el ID del usuario actual con manejo seguro
  String? get _userId => _client.auth.currentUser?.id;

  // Obtener todos los ejercicios del usuario actual
  Future<List<Exercise>> getExercises() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('ejercicio')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Exercise.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }

  // Crear un nuevo ejercicio vinculado al usuario
  Future<void> createExercise(
      String nombre, ExerciseType tipo, String? descripcion) async {
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
      print('Error creating exercise: $e');
      rethrow;
    }
  }

  // Modificar un ejercicio existente
  Future<void> updateExercise(
      int id, String nombre, ExerciseType tipo, String? descripcion) async {
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
      print('Error updating exercise: $e');
      rethrow;
    }
  }

  // Eliminar un ejercicio
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
      print('Error deleting exercise: $e');
      rethrow;
    }
  }

  // Crear una nueva rutina
  // En RoutineService
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

  // Obtener todas las rutinas del usuario
  Future<List<Routine>> getRoutines() async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('rutina')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => Routine.fromMap(e)).toList();
    } catch (e) {
      print('Error fetching routines: $e');
      return [];
    }
  }

  // Asignar ejercicio a rutina con detalles
  Future<void> addExerciseToRutina({
    required int rutinaId,
    required int ejercicioId,
    required int series,
    required int repeticiones,
    double? duracion,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verificar que la rutina pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Routine not found or not owned by user');

      // Verificar que el ejercicio pertenece al usuario
      final exercise = await _client
          .from('ejercicio')
          .select()
          .eq('id', ejercicioId)
          .eq('user_id', userId)
          .maybeSingle();

      if (exercise == null) throw Exception('Exercise not found or not owned by user');

      // Convertir double? a int? para Supabase
      int? duracionInt = duracion?.round();

      await _client.from('ejerciciorutina').insert({
        'rutina_id': rutinaId,
        'ejercicio_id': ejercicioId,
        'series': series,
        'repeticiones': repeticiones,
        'duracion': duracionInt,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error adding exercise to routine: $e');
      rethrow;
    }
  }

  // Obtener ejercicios de una rutina con detalles
  Future<List<Map<String, dynamic>>> getEjerciciosForRutina(int rutinaId) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      // Verificar que la rutina pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) return [];

      final response = await _client
          .from('ejerciciorutina')
          .select('series, repeticiones, duracion, created_at, ejercicio (*)')
          .eq('rutina_id', rutinaId)
          .order('created_at', ascending: false);

      return (response as List).map((item) {
        final ejercicio = Exercise.fromMap(item['ejercicio']);
        return {
          'ejercicio': ejercicio,
          'series': item['series'],
          'repeticiones': item['repeticiones'],
          'duracion': item['duracion'] as int?,
          'created_at': item['created_at'],
        };
      }).toList();
    } catch (e) {
      print('Error fetching routine exercises: $e');
      return [];
    }
  }

  // Eliminar un ejercicio de una rutina
  Future<void> deleteExerciseFromRutina(int rutinaId, int ejercicioId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verificar que la rutina pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Routine not found or not owned by user');

      await _client
          .from('ejerciciorutina')
          .delete()
          .match({
        'rutina_id': rutinaId,
        'ejercicio_id': ejercicioId,
      });
    } catch (e) {
      print('Error removing exercise from routine: $e');
      rethrow;
    }
  }

  // Verificar si una rutina pertenece al usuario
  Future<bool> doesRoutineBelongToUser(int rutinaId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking routine ownership: $e');
      return false;
    }
  }

  // Verificar si un ejercicio pertenece al usuario
  Future<bool> doesExerciseBelongToUser(int ejercicioId) async {
    final userId = _userId;
    if (userId == null) return false;

    try {
      final response = await _client
          .from('ejercicio')
          .select()
          .eq('id', ejercicioId)
          .eq('user_id', userId);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking exercise ownership: $e');
      return false;
    }
  }

  // Obtener una rutina por ID
  Future<Routine?> getRoutineById(int rutinaId) async {
    final userId = _userId;
    if (userId == null) return null;

    try {
      final response = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      return response != null ? Routine.fromMap(response) : null;
    } catch (e) {
      print('Error getting routine by ID: $e');
      return null;
    }
  }
}