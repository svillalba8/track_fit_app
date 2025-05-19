class EjercicioRutina {
  final int id;
  final int idRutina;
  final int idEjercicio;
  final DateTime createdAt;
  final int series;
  final int? repeticiones;
  final int? duracion; // Cambiado a int?

  EjercicioRutina({
    required this.id,
    required this.idRutina,
    required this.idEjercicio,
    required this.createdAt,
    required this.series,
    this.repeticiones,
    this.duracion,
  });

  factory EjercicioRutina.fromMap(Map<String, dynamic> map) {
    return EjercicioRutina(
      id: map['id'] as int,
      idRutina: map['id_rutina'] as int,
      idEjercicio: map['id_ejercicio'] as int,
      createdAt: DateTime.parse(map['created_at']),
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int?,
      duracion: map['duracion'] as int?, // Cambiado a int?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_rutina': idRutina,
      'id_ejercicio': idEjercicio,
      'series': series,
      'repeticiones': repeticiones,
      'duracion': duracion,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Método auxiliar para obtener la duración como double si es necesario
  double? get duracionAsDouble => duracion?.toDouble();
}