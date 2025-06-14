import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/enums/exercise_type.dart';
import '../models/exercise_model.dart';

/// Servicio encargado de las operaciones CRUD sobre ejercicios del usuario.
class ExerciseService {
  /// Cliente de Supabase para realizar consultas.
  final SupabaseClient _client = Supabase.instance.client;

  /// ID del usuario autenticado, o null si no hay sesión activa.
  String? get _userId => _client.auth.currentUser?.id;

  /// Obtiene la lista de ejercicios del usuario actual, ordenados por fecha de creación.
  /// - Retorna lista vacía si no hay usuario autenticado o en caso de error.
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
      return [];
    }
  }

  /// Crea un nuevo ejercicio asociándolo al usuario actual.
  /// - [nombre]: nombre del ejercicio.
  /// - [tipo]: tipo de ejercicio (fuerza, cardio, intenso).
  /// - [descripcion]: descripción opcional.
  /// - Lanza excepción si no hay usuario autenticado o en caso de error.
  Future<void> createExercise(
    String nombre,
    ExerciseType tipo,
    String? descripcion,
  ) async {
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
      rethrow;
    }
  }

  /// Actualiza un ejercicio existente.
  /// - [id]: identificador del ejercicio.
  /// - [nombre]: nuevo nombre.
  /// - [tipo]: nuevo tipo.
  /// - [descripcion]: nueva descripción opcional.
  /// - Lanza excepción si no hay usuario autenticado o en caso de error.
  Future<void> updateExercise(
    int id,
    String nombre,
    ExerciseType tipo,
    String? descripcion,
  ) async {
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
      rethrow;
    }
  }

  /// Elimina un ejercicio del usuario actual.
  /// - [id]: identificador del ejercicio a eliminar.
  /// - Lanza excepción si no hay usuario autenticado o en caso de error.
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
      rethrow;
    }
  }
}
