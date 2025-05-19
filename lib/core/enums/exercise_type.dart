enum ExerciseType {
  fuerza,
  cardio,
  intenso,
}

extension ExerciseTypeExtension on ExerciseType {
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