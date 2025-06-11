import 'exercise_model.dart';

class ExerciseWithDetails {
  final String id;
  final String routineId;
  final Exercise ejercicio;
  final int series;
  final int repeticiones;
  final int duracion;

  ExerciseWithDetails({
    required this.id,
    required this.routineId,
    required this.ejercicio,
    required this.series,
    required this.repeticiones,
    required this.duracion,
  });

  factory ExerciseWithDetails.fromMap(Map<String, dynamic> map) {
    return ExerciseWithDetails(
      id: map['id'],
      routineId: map['rutina_id'],
      ejercicio: Exercise.fromMap(map['ejercicio']),
      series: map['series'],
      repeticiones: map['repeticiones'],
      duracion: map['duracion'],
    );
  }
}
