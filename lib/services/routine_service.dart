import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/enums/exercise_type.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';

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

  // Nuevo método: Obtener ejercicios de una rutina específica
  Future<List<Exercise>> getExercisesForRoutine(int routineId) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('ejercicio_rutina')
          .select('''
            id_ejercicio,
            ejercicio:ejercicio_id(*)
          ''')
          .eq('id_rutina', routineId);

      return (data as List)
          .map((e) => Exercise.fromMap(e['ejercicio']))
          .toList();
    } catch (e) {
      print('Error al obtener ejercicios de rutina: $e');
      return [];
    }
  }

  // Nuevo método: Obtener detalles completos de ejercicios en rutina
  Future<List<Map<String, dynamic>>> getRoutineExercisesDetails(int routineId) async {
    final userId = _userId;
    if (userId == null) return [];

    try {
      final data = await _client
          .from('ejercicio_rutina')
          .select('''
            id_ejercicio,
            series,
            repeticiones,
            duracion,
            ejercicio:ejercicio_id(*)
          ''')
          .eq('id_rutina', routineId);

      return (data as List).cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error al obtener detalles de ejercicios en rutina: $e');
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

  // Nuevo método: Actualizar nombre de rutina
  Future<void> updateRoutine(int routineId, String newName) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('rutina')
          .update({
        'nombre': newName,
      })
          .eq('id', routineId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al actualizar rutina: $e');
      rethrow;
    }
  }

  // Nuevo método: Eliminar todos los ejercicios de una rutina
  Future<void> removeAllExercisesFromRoutine(int routineId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verificar que la rutina pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', routineId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Rutina no encontrada o no pertenece al usuario.');

      await _client
          .from('ejercicio_rutina')
          .delete()
          .eq('id_rutina', routineId);
    } catch (e) {
      print('Error al eliminar ejercicios de rutina: $e');
      rethrow;
    }
  }

  // Nuevo método: Eliminar un ejercicio específico de una rutina
  Future<void> removeExerciseFromRoutine(int routineId, int exerciseId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Verificar que la rutina pertenece al usuario
      final routine = await _client
          .from('rutina')
          .select()
          .eq('id', routineId)
          .eq('user_id', userId)
          .maybeSingle();

      if (routine == null) throw Exception('Rutina no encontrada o no pertenece al usuario.');

      await _client
          .from('ejercicio_rutina')
          .delete()
          .eq('id_rutina', routineId)
          .eq('id_ejercicio', exerciseId);
    } catch (e) {
      print('Error al eliminar ejercicio de rutina: $e');
      rethrow;
    }
  }

  /// Eliminar una rutina y sus asociaciones
  Future<void> deleteRoutine(int rutinaId) async {
    final userId = _userId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      // Eliminar ejercicios asociados
      await _client
          .from('ejercicio_rutina')
          .delete()
          .eq('id_rutina', rutinaId);

      // Eliminar rutina
      await _client
          .from('rutina')
          .delete()
          .eq('id', rutinaId)
          .eq('user_id', userId);
    } catch (e) {
      print('Error al eliminar rutina: $e');
      rethrow;
    }
  }
}