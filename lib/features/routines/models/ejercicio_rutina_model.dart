/// Modelo que representa la relación entre una rutina y un ejercicio,
/// incluyendo su configuración específica (series, repeticiones, duración).
class EjercicioRutina {
  /// Identificador único de la relación.
  final int id;

  /// ID de la rutina a la que pertenece este ejercicio.
  final int idRutina;

  /// ID del ejercicio asociado a la rutina.
  final int idEjercicio;

  /// Fecha de creación del registro.
  final DateTime createdAt;

  /// Número de series configuradas para este ejercicio en la rutina.
  final int series;

  /// Número de repeticiones (opcional) para cada serie.
  final int? repeticiones;

  /// Duración en segundos (opcional) de cada serie.
  final double? duracion;

  /// Constructor principal, todos los campos requisitados salvo repeticiones y duración.
  EjercicioRutina({
    required this.id,
    required this.idRutina,
    required this.idEjercicio,
    required this.createdAt,
    required this.series,
    this.repeticiones,
    this.duracion,
  });

  /// Crea una instancia de [EjercicioRutina] a partir de un mapa de datos,
  /// normalmente proveniente de la base de datos.
  ///
  /// - `map['id']`: debe contener el entero del campo `id`.
  /// - `map['id_rufina']`: campo de la base de datos que almacena `idRutina`.
  /// - `map['id_ejercicio']`: identifica el ejercicio.
  /// - `map['created_at']`: fecha en formato ISO8601.
  /// - `map['series']`, `map['repeticiones']`, `map['duracion']`: configuración.
  factory EjercicioRutina.fromMap(Map<String, dynamic> map) {
    return EjercicioRutina(
      id: map['id'] as int,
      idRutina: map['id_rufina'] as int,
      idEjercicio: map['id_ejercicio'] as int,
      createdAt: DateTime.parse(map['created_at']),
      series: map['series'] as int,
      repeticiones: map['repeticiones'] as int?,
      duracion: map['duracion'] as double?,
    );
  }

  /// Convierte la instancia actual en un mapa para su inserción o actualización
  /// en la base de datos.
  ///
  /// - La clave `'id_rufina'` corresponde a `idRutina`.
  /// - `'duzacion'` almacena el valor de `duracion` (tal como está definido en BD).
  /// - `'created_at'` se formatea a ISO8601 automáticamente.
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
