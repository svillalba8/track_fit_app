import 'package:dartz/dartz.dart';
import '../errors/failures.dart'; // Asegúrate de que esta importación sea correcta
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String email,
    required String password,
    required String name,
    required String surnames,
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String userName,
    required String status,
    required String description,
    int? idProgress,
  }) async {
    final usuario = Usuario(
      authUserId: '', // Supabase lo generará
      mail: email,
      name: name,
      surnames: surnames,
      age: age,
      weight: weight,
      height: height,
      gender: gender,
      userName: userName,
      status: status,
      idProgress: idProgress,
      description: description,
    );

    try {
      // Intentamos registrar el usuario a través del repositorio
      await repository.registerUser(
        email: email,
        password: password,
        usuario: usuario,
      );
      return const Right(null); // Retornamos un Right con null en caso de éxito
    } catch (e) {
      // Dependiendo del tipo de error, lanzamos la subclase adecuada de Failure
      if (e is AuthFailure) {
        return Left(AuthFailure(message: e.message)); // Error de autenticación
      } else if (e is ServerFailure) {
        return Left(ServerFailure(message: e.message)); // Error del servidor
      } else if (e is NetworkFailure) {
        return Left(NetworkFailure(message: e.message)); // Error de red
      } else {
        return Left(ServerFailure(message: 'Error desconocido: ${e.toString()}')); // Error genérico del servidor
      }
    }
  }
}
