class ProgresoModel {
  // Identificador único del progreso
  final int id;
  // Fecha de inicio del progreso
  final DateTime fechaComienzo;
  // Objetivo de peso (puede ser null si no se estableció)
  final double? objetivoPeso;
  // Fecha límite para alcanzar el objetivo (puede ser null)
  final DateTime? fechaObjetivo;
  // Peso inicial al crear el progreso
  final double pesoInicial;

  ProgresoModel({
    required this.id,
    required this.fechaComienzo,
    this.objetivoPeso,
    this.fechaObjetivo,
    required this.pesoInicial,
  });

  /// Crea una instancia a partir de un JSON de la base de datos
  factory ProgresoModel.fromJson(Map<String, dynamic> json) => ProgresoModel(
    id: json['id'] as int,
    fechaComienzo: DateTime.parse(json['fecha_comienzo'] as String),
    objetivoPeso:
        json['objetivo_peso'] != null
            ? (json['objetivo_peso'] as num).toDouble()
            : null,
    fechaObjetivo:
        json['fecha_objetivo'] != null
            ? DateTime.tryParse(json['fecha_objetivo'] as String)
            : null,
    pesoInicial: (json['peso_inicial'] as num).toDouble(),
  );

  /// Devuelve una copia del modelo con campos modificados opcionalmente
  ProgresoModel copyWith({
    int? id,
    DateTime? fechaComienzo,
    double? objetivoPeso,
    DateTime? fechaObjetivo,
    double? pesoInicial,
  }) {
    return ProgresoModel(
      id: id ?? this.id,
      fechaComienzo: fechaComienzo ?? this.fechaComienzo,
      objetivoPeso: objetivoPeso ?? this.objetivoPeso,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      pesoInicial: pesoInicial ?? this.pesoInicial,
    );
  }
}
