class Routine {
  final int id;
  final String nombre;

  Routine({
    required this.id,
    required this.nombre,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

