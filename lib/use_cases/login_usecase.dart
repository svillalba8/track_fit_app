import 'package:dartz/dartz.dart';

import '../errors/failures.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<Either<Failure, dynamic>> call(String email, String password) {

    return repository.login(email: email, password: password);
  }
}
