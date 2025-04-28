import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../repositories/auth_repository.dart';

class CerrarSesionUseCase {
  final AuthRepository repository;

  CerrarSesionUseCase({required this.repository});

  Future<Either<Failure, void>> call() async {
    try {
      await repository.cerrarSesion();
      return const Right(null); // Significa éxito
    } catch (e) {
      return Left(ServerFailure(message: e.toString())); // Significa error
    }
  }
}
