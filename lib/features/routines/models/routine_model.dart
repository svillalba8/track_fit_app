class Routine {
  final int id;
  final String nombre;
  final String? userId;

  Routine({
    required this.id,
    required this.nombre,
    this.userId,
  });

  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: int.parse(map['id'].toString()),
      nombre: map['nombre'] as String,
      userId: map['user_id'] as String?,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'user_id': userId,
    };
  }
}