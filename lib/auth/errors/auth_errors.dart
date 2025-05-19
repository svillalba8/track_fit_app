abstract class Failure {
  final String message;
  const Failure({this.message = "Error desconocido"});
}

class ServerFailure extends Failure {
  const ServerFailure({String message = "Error del servidor"}) : super(message: message);
}

class AuthFailure extends Failure {
  const AuthFailure({String message = "Error de autenticación"}) : super(message: message);
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure({String message = "Usuario no encontrado"}) : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({String message = "Error de red"}) : super(message: message);
}
