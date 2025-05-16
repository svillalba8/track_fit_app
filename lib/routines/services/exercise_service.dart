import 'package:supabase_flutter/supabase_flutter.dart';
import '../enums/exercise_type.dart';
import '../models/exercise.dart';

class ExerciseService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

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
}