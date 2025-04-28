import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../models/usuario.dart';

abstract class AuthRepository {
  Future<Either<Failure, dynamic>> registerUser({
    required String email,
    required String password,
    required Usuario usuario,
  });

  Future<Either<Failure, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> cerrarSesion();

  Future<Either<Failure, Usuario?>> getCurrentUser();
}
