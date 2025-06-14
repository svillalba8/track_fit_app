/// Tipos de ejercicio disponibles en la app
enum ExerciseType {
  fuerza, // Entrenamiento de fuerza
  cardio, // Ejercicio cardiovascular
  intenso, // Ejercicio de alta intensidad
}

extension ExerciseTypeExtension on ExerciseType {
  /// Nombre legible del tipo de ejercicio (coincide con el enum)
  String get name {
    switch (this) {
      case ExerciseType.fuerza:
        return 'fuerza';
      case ExerciseType.cardio:
        return 'cardio';
      case ExerciseType.intenso:
        return 'intenso';
    }
  }

  /// Convierte un string (p. ej. desde la base de datos) en ExerciseType
  /// - Si no coincide, devuelve fuerza por defecto
  static ExerciseType fromString(String type) {
    switch (type) {
      case 'fuerza':
        return ExerciseType.fuerza;
      case 'cardio':
        return ExerciseType.cardio;
      case 'intenso':
        return ExerciseType.intenso;
      default:
        return ExerciseType.fuerza;
    }
  }
}
