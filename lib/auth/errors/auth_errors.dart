abstract class Failure {
  final String message;
  const Failure({this.message = "Error desconocido"});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = "Error del servidor"});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = "Error de autenticación"});
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({super.message = "Usuario no encontrado"});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "Error de red"});
}
