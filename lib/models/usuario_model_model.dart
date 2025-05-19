class UsuarioModel {
  final int id;
  final String nombreUsuario;
  final String? descripcion;
  final double peso;
  final double estatura;
  final String genero;
  final String nombre;
  final String apellidos;
  final String authUsersId;
  final int? idProgreso;

  UsuarioModel({
    required this.id,
    required this.nombreUsuario,
    required this.descripcion,
    required this.peso,
    required this.estatura,
    required this.genero,
    required this.nombre,
    required this.apellidos,
    required this.authUsersId,
    required this.idProgreso,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as int,
      nombreUsuario: json['nombre_usuario'] as String,
      descripcion: json['descripcion'] as String?,
      peso: (json['peso'] as num).toDouble(),
      estatura: (json['estatura'] as num).toDouble(),
      genero: json['genero'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      authUsersId: json['auth_user_id'] as String,
      idProgreso: json['id_progreso'] as int?,
    );
  }
}
