import '../../../core/enums/exercise_type.dart';

/// Modelo que representa un ejercicio definido por el usuario.
/// Contiene metadatos y descripción opcional.
class Exercise {
  /// Identificador único del ejercicio.
  final int id;

  /// Fecha de creación del registro.
  final DateTime createdAt;

  /// Nombre del ejercicio.
  final String nombre;

  /// Tipo de ejercicio (fuerza, cardio, intenso).
  final ExerciseType tipo;

  /// Descripción opcional del ejercicio.
  final String? descripcion;

  /// ID del usuario que creó el ejercicio (para validaciones).
  final String? userId;

  /// Constructor principal, todos los campos requeridos salvo descripción y userId.
  Exercise({
    required this.id,
    required this.createdAt,
    required this.nombre,
    required this.tipo,
    this.descripcion,
    this.userId,
  });

  /// Crea una instancia de [Exercise] a partir de un mapa,
  /// normalmente obtenido de la base de datos.
  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at']),
      nombre: map['nombre'] as String,
      // Convierte la cadena almacenada en la BD al enum correspondiente.
      tipo: ExerciseTypeExtension.fromString(map['tipo'] as String),
      descripcion: map['descripcion'] as String?,
      userId: map['user_id'] as String?,
    );
  }

  /// Convierte la instancia actual en un mapa para insertar o actualizar
  /// en la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'nombre': nombre,
      // Almacena el nombre del enum para persistencia.
      'tipo': tipo.name,
      'descripcion': descripcion,
      'user_id': userId,
    };
  }
}
