/// Clase base para errores, contiene un mensaje descriptivo
abstract class Failure {
  final String message; // Mensaje de error
  const Failure({this.message = "Error desconocido"});
}

/// Error genérico de servidor
class ServerFailure extends Failure {
  const ServerFailure({super.message = "Error del servidor"});
}

/// Error de autenticación (p. ej. credenciales inválidas)
class AuthFailure extends Failure {
  const AuthFailure({super.message = "Error de autenticación"});
}

/// Indica que no se encontró el usuario solicitado
class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({super.message = "Usuario no encontrado"});
}

/// Error de conexión o de red
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "Error de red"});
}
