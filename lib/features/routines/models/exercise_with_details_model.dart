import 'exercise_model.dart';

/// Modelo que extiende [Exercise] con detalles específicos de su inclusión
/// en una rutina: número de series, repeticiones y duración.
class ExerciseWithDetails {
  /// Identificador único de la relación ejercicio–rutina.
  final String id;

  /// Identificador de la rutina a la que pertenece este ejercicio.
  final String routineId;

  /// Objeto [Exercise] con los datos básicos del ejercicio.
  final Exercise ejercicio;

  /// Número de series configuradas para este ejercicio en la rutina.
  final int series;

  /// Número de repeticiones por serie.
  final int repeticiones;

  /// Duración en segundos de cada serie.
  final int duracion;

  /// Constructor principal con todos los campos requeridos.
  ExerciseWithDetails({
    required this.id,
    required this.routineId,
    required this.ejercicio,
    required this.series,
    required this.repeticiones,
    required this.duracion,
  });

  /// Crea una instancia de [ExerciseWithDetails] a partir de un mapa de datos,
  /// típico de la respuesta de la base de datos con join sobre la tabla de ejercicios.
  factory ExerciseWithDetails.fromMap(Map<String, dynamic> map) {
    return ExerciseWithDetails(
      // 'id' proviene del registro en la tabla intermedia.
      id: map['id'] as String,
      // 'rutina_id' referencia la rutina padre.
      routineId: map['rutina_id'] as String,
      // Mapea el subobjeto 'ejercicio' a la clase [Exercise].
      ejercicio: Exercise.fromMap(map['ejercicio'] as Map<String, dynamic>),
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int,
      duracion: map['duracion'] as int,
    );
  }
}
