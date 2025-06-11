import '../../../core/enums/exercise_type.dart';

class Exercise {
  final int id;
  final DateTime createdAt;
  final String nombre;
  final ExerciseType tipo;
  final String? descripcion;
  final String? userId;

  Exercise({
    required this.id,
    required this.createdAt,
    required this.nombre,
    required this.tipo,
    this.descripcion,
    this.userId,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at']),
      nombre: map['nombre'] as String,
      tipo: ExerciseTypeExtension.fromString(map['tipo'] as String),
      descripcion: map['descripcion'],
      userId: map['user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'nombre': nombre,
      'tipo': tipo.name,
      'descripcion': descripcion,
      'user_id': userId,
    };
  }
}