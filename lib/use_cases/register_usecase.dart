import 'package:dartz/dartz.dart';
import '../errors/failures.dart'; // Asegúrate de que esta importación sea correcta
import '../models/usuario.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});


  @override
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
      authUserId: '', // Se actualizará después del registro en Auth
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
      final result = await repository.registerUser(
        email: email,
        password: password,
        usuario: usuario,
      );

      return result.fold(
            (failure) => Left(failure),
            (_) => const Right(null),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Error durante el registro: $e'));
    }
  }
}
