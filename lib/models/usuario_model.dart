class UsuarioModel {
  // ID interno de la tabla 'usuarios'
  final int id;
  // Nombre de usuario único para mostrar
  final String nombreUsuario;
  // Descripción o biografía opcional
  final String? descripcion;
  // Peso actual del usuario
  final double peso;
  // Estatura del usuario en cm
  final double estatura;
  // Género
  final String genero;
  // Nombre de pila del usuario
  final String nombre;
  // Apellidos del usuario
  final String apellidos;
  // ID de autenticación de Supabase (UUID)
  final String authUsersId;
  // ID de progreso activo (puede ser null si no tiene)
  final int? idProgreso;
  // Fecha de nacimiento
  final DateTime fechaNac;

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
    required this.fechaNac,
  });

  /// Crea el modelo a partir del JSON de la BD
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
      fechaNac: DateTime.parse(json['fecha_nac'] as String),
    );
  }

  /// Devuelve una copia del modelo con campos opcionalmente modificados
  UsuarioModel copyWith({
    int? id,
    String? nombreUsuario,
    String? descripcion,
    double? peso,
    double? estatura,
    String? genero,
    String? nombre,
    String? apellidos,
    String? authUsersId,
    int? idProgreso,
    DateTime? fechaNac,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      descripcion: descripcion ?? this.descripcion,
      peso: peso ?? this.peso,
      estatura: estatura ?? this.estatura,
      genero: genero ?? this.genero,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      authUsersId: authUsersId ?? this.authUsersId,
      idProgreso: idProgreso ?? this.idProgreso,
      fechaNac: fechaNac ?? this.fechaNac,
    );
  }

  /// Calcula la edad actual basándose en la fecha de nacimiento
  int? getEdad() {
    final today = DateTime.now();
    int edad = today.year - fechaNac.year;
    // Si no ha cumplido años este año, resta uno
    if (today.month < fechaNac.month ||
        (today.month == fechaNac.month && today.day < fechaNac.day)) {
      edad--;
    }
    return edad;
  }
}
