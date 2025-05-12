import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../errors/failures.dart';
import '../models/usuario.dart';
import '../sources/auth_source.dart';
import '../sources/usuario_source.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthSource _authSource;
  final UsuarioSource _usuarioSource;

  AuthRepositoryImpl({
    required AuthSource authSource,
    required UsuarioSource usuarioSource,
  })  : _authSource = authSource,
        _usuarioSource = usuarioSource;

  @override
  Future<Either<Failure, void>> registerUser({
    required String email,
    required String password,
    required Usuario usuario,
  }) async {
    try {
      // Validar si el email es único
      final emailValidation = await _authSource.validateUniqueEmail(email);
      if (emailValidation.isLeft()) {
        return emailValidation;
      }

      // Registrar usuario en el sistema de autenticación
      final authResponse = await _authSource.register(email, password);

      return await authResponse.fold(
            (failure) => Left(failure),
            (response) async {
          final user = response.user;
          if (user == null) {
            return Left(AuthFailure(message: 'User registration failed'));
          }

          // Crear nuevo usuario con el authUserId
          final newUsuario = Usuario(
            id: usuario.id,
            authUserId: user.id,
            mail: email,
            name: usuario.name,
            surnames: usuario.surnames,
            age: usuario.age,
            weight: usuario.weight,
            height: usuario.height,
            gender: usuario.gender,
            userName: usuario.userName,
            status: usuario.status,
            idProgress: usuario.idProgress,
            description: usuario.description,
          );

          try {
            await _usuarioSource.createUser(newUsuario);
            return const Right(null);
          } catch (e) {
            // Revertir la creación en auth si falla
            await _authSource.cerrarSesion();
            return Left(ServerFailure(message: 'Failed to create user: $e'));
          }
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Usuario>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _authSource.login(email, password);

      return await authResponse.fold(
            (failure) => Left(failure),
            (response) async {
          final user = response.user;
          if (user == null) {
            return Left(AuthFailure(message: 'Login failed - no user returned'));
          }

          // Obtener detalles del usuario desde la base de datos
          final usuario = await _usuarioSource.getUserById(user.id);
          if (usuario == null) {
            return Left(UserNotFoundFailure());
          }

          return Right(usuario);
        },
      );
    } catch (e) {
      return Left(AuthFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cerrarSesion() async {
    try {
      await _authSource.cerrarSesion();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Usuario?>> getCurrentUser() async {
    try {
      final authUserResult = await _authSource.getCurrentUser();

      return await authUserResult.fold(
            (failure) => Left(failure),
            (authUser) async {
          if (authUser == null) {
            return const Right(null);
          }

          // Obtener detalles del usuario desde la base de datos
          final usuario = await _usuarioSource.getUserById(authUser.authUserId);
          return Right(usuario);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: $e'));
    }
  }
}