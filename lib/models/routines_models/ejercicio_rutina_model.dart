class EjercicioRutina {
  final int id;
  final int idRutina;
  final int idEjercicio;
  final DateTime createdAt;
  final int series;
  final int? repeticiones;
  final double? duracion;

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
      idRutina: map['id_rufina'] as int,
      idEjercicio: map['id_ejercicio'] as int,
      createdAt: DateTime.parse(map['created_at']),
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int?,
      duracion: map['duzacion'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_rufina': idRutina,
      'id_ejercicio': idEjercicio,
      'series': series,
      'repeticiones': repeticiones,
      'duzacion': duracion,
      'created_at': createdAt.toIso8601String(),
    };
  }
}