import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/routines/enums/exercise_type.dart';
import '../models/exercise_model.dart';
import '../models/routine_model.dart';

class RoutineService {
  final SupabaseClient _client = Supabase.instance.client;

  // Obtener todos los ejercicios
  Future<List<Exercise>> getExercises() async {
    final response = await _client.from('ejercicio').select();
    return (response as List).map((e) => Exercise.fromMap(e)).toList();
  }

  // Crear un nuevo ejercicio
  Future<void> createExercise(
    String nombre,
    ExerciseType tipo,
    String? descripcion,
  ) async {
    await _client.from('ejercicio').insert({
      'nombre': nombre,
      'tipo': tipo.name,
      'descripcion': descripcion,
    });
  }

  // Modificar un ejercicio existente
  Future<void> updateExercise(
    int id,
    String nombre,
    ExerciseType tipo,
    String? descripcion,
  ) async {
    await _client
        .from('ejercicio')
        .update({
          'nombre': nombre,
          'tipo': tipo.name,
          'descripcion': descripcion,
        })
        .eq('id', id);
  }

  // Eliminar un ejercicio
  Future<void> deleteExercise(int id) async {
    await _client.from('ejercicio').delete().eq('id', id);
  }

  // Crear una nueva rutina
  Future<void> createRoutine(String nombre) async {
    await _client.from('rutina').insert({'nombre': nombre});
  }

  // Obtener todas las rutinas
  Future<List<Routine>> getRoutines() async {
    final response = await _client.from('rutina').select();
    return (response as List).map((e) => Routine.fromMap(e)).toList();
  }

  // Asignar ejercicio a rutina con detalles
  Future<void> addExerciseToRutina({
    required int rutinaId,
    required int ejercicioId,
    required int series,
    required int repeticiones,
    int? duracion,
  }) async {
    await _client.from('ejerciciorutina').insert({
      'rutina_id': rutinaId,
      'ejercicio_id': ejercicioId,
      'series': series,
      'repeticiones': repeticiones,
      'duracion': duracion,
    });
  }

  // Obtener ejercicios de una rutina con detalles
  Future<List<Map<String, dynamic>>> getEjerciciosForRutina(
    int rutinaId,
  ) async {
    final response = await _client
        .from('ejerciciorutina')
        .select('series, repeticiones, duracion, ejercicio (*)')
        .eq('rutina_id', rutinaId);

    return (response as List).map((item) {
      final ejercicio = Exercise.fromMap(item['ejercicio']);
      return {
        'ejercicio': ejercicio,
        'series': item['series'],
        'repeticiones': item['repeticiones'],
        'duracion': item['duracion'],
      };
    }).toList();
  }

  // Eliminar un ejercicio de una rutina
  Future<void> deleteExerciseFromRutina(int rutinaId, int ejercicioId) async {
    await _client.from('ejerciciorutina').delete().match({
      'rutina_id': rutinaId,
      'ejercicio_id': ejercicioId,
    });
  }
}
