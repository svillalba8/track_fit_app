class ProgresoModel {
  final int id;
  final DateTime fechaComienzo;
  final double objetivoPeso;
  final DateTime? fechaObjetivo;
  final double pesoActual;
  final double? pesoInicial;

  ProgresoModel({
    required this.id,
    required this.fechaComienzo,
    required this.objetivoPeso,
    this.fechaObjetivo,
    required this.pesoActual,
    this.pesoInicial,
  });

  factory ProgresoModel.fromJson(Map<String, dynamic> json) => ProgresoModel(
    id: json['id'] as int,
    fechaComienzo: DateTime.parse(json['fecha_comienzo'] as String),
    objetivoPeso: (json['objetivo_peso'] as num).toDouble(),
    fechaObjetivo:
        json['fecha_objetivo'] != null
            ? DateTime.tryParse(json['fecha_objetivo'] as String)
            : null,
    pesoActual: (json['peso_actual'] as num).toDouble(),
    pesoInicial:
        json['peso_inicial'] != null
            ? (json['peso_inicial'] as num).toDouble()
            : null,
  );

  ProgresoModel copyWith({
    int? id,
    DateTime? fechaComienzo,
    double? objetivoPeso,
    DateTime? fechaObjetivo,
    double? pesoActual,
    double? pesoInicial,
  }) {
    return ProgresoModel(
      id: id ?? this.id,
      fechaComienzo: fechaComienzo ?? this.fechaComienzo,
      objetivoPeso: objetivoPeso ?? this.objetivoPeso,
      fechaObjetivo: fechaObjetivo ?? this.fechaObjetivo,
      pesoActual: pesoActual ?? this.pesoActual,
      pesoInicial: pesoInicial ?? this.pesoInicial,
    );
  }
}
