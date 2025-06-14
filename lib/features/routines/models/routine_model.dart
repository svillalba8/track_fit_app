/// Modelo que representa una rutina de entrenamiento.
/// - [id]: identificador único de la rutina.
/// - [nombre]: nombre descriptivo de la rutina.
/// - [userId]: ID opcional del usuario que la creó.
class Routine {
  /// Identificador único de la rutina.
  final int id;

  /// Nombre de la rutina.
  final String nombre;

  /// ID del usuario propietario (puede ser nulo).
  final String? userId;

  /// Constructor principal. [id] y [nombre] son obligatorios; [userId] es opcional.
  Routine({required this.id, required this.nombre, this.userId});

  /// Crea una instancia de [Routine] a partir de un mapa de datos,
  /// normalmente obtenido de la base de datos.
  ///
  /// - Convierte ‘id’ a entero incluso si viene como cadena.
  /// - Lee ‘nombre’ como String.
  /// - Lee ‘user_id’ como String? para permitir valores nulos.
  factory Routine.fromMap(Map<String, dynamic> map) {
    return Routine(
      id: int.parse(map['id'].toString()),
      nombre: map['nombre'] as String,
      userId: map['user_id'] as String?,
    );
  }

  /// Convierte la instancia actual en un mapa de valores para persistir
  /// en la base de datos o enviarla en una petición.
  ///
  /// - Incluye ‘id’, ‘nombre’ y ‘user_id’.
  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'user_id': userId};
  }
}
