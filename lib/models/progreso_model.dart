class ProgresoModel {
  final int id;
  final DateTime fechaComienzo;
  final double? objetivoPeso;
  final DateTime? fechaObjetivo;
  final double pesoInicial;

  ProgresoModel({
    required this.id,
    required this.fechaComienzo,
    this.objetivoPeso,
    this.fechaObjetivo,
    required this.pesoInicial,
  });

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
