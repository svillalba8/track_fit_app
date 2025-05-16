import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/exercise_type.dart';
import '../models/exercise.dart';
import '../models/routine.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // Obtener todos los ejercicios del usuario actual
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
    required int repeticiones,
    double? duracion,
  }) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verificar que la rutina existe y pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', rutinaId)
          .eq('user_id', userId)
          .maybeSingle();

      // Verificar que el ejercicio existe y pertenece al usuario
      final exercise = await _client
          .from('ejercicio')
          .select()
          .eq('id', ejercicioId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Rutina no encontrada o no pertenece al usuario.');
      if (exercise == null) throw Exception('Ejercicio no encontrado o no pertenece al usuario.');

      // Insertar en la tabla ejercicio_rutina (con guion bajo y claves correctas)
      await _client.from('ejercicio_rutina').insert({
        'id_rutina': rutinaId,
        'id_ejercicio': ejercicioId,
        'series': series,
        'repeticiones': repeticiones,
        'duracion': duracion, // Si es double, insertarlo así directamente
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error al añadir ejercicio a la rutina: $e');
      rethrow;
    }
  }


}
