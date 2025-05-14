import '../enums/exercise_type.dart';

class Exercise {
  final int id;
  final String nombre;
  final ExerciseType tipo;
  final String? descripcion;

  Exercise({
    required this.id,
    required this.nombre,
    required this.tipo,
    this.descripcion,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      tipo: ExerciseTypeExtension.fromString(map['tipo'] as String),
      descripcion: map['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo.name,
      'descripcion': descripcion,
    };
  }
}