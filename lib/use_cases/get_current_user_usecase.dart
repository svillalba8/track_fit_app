import '../models/usuario.dart';
import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  Future<Usuario?> call() async {
    final result = await repository.getCurrentUser();

    return result.fold(
          (failure) {
        print("Error obteniendo el usuario: ${failure.message}");
        return null;
      },
          (usuario) => usuario,
    );
  }
}
