import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../errors/failures.dart';
import '../models/usuario.dart';

abstract class AuthSource {
  Future<Either<Failure, supabase.AuthResponse>> register(String email, String password);
  Future<Either<Failure, supabase.AuthResponse>> login(String email, String password);
  Future<Either<Failure, void>> cerrarSesion();
  Future<Either<Failure, Usuario?>> getCurrentUser();
  Future<Either<Failure, void>> validateUniqueEmail(String email);
}

class AuthSourceImpl implements AuthSource {
  final supabase.SupabaseClient supabaseClient = supabase.Supabase.instance.client;

  @override
  Future<Either<Failure, supabase.AuthResponse>> register(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      return Right(response);
    } catch (e) {
      return Left(AuthFailure(message: "Error al registrar usuario: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, supabase.AuthResponse>> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Right(response);
    } catch (e) {
      return Left(AuthFailure(message: "Error al iniciar sesión: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, Usuario?>> getCurrentUser() async {
    try {
      final user = supabaseClient.auth.currentUser;
      return Right(user != null ? Usuario.fromAuthUser(user) : null);
    } catch (e) {
      return Left(AuthFailure(message: "Error obteniendo usuario: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, void>> cerrarSesion() async {
    try {
      await supabaseClient.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: "Error al cerrar sesión: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, bool>> validateUniqueEmail(String email) async {
    try {
      // Obtener la respuesta como dynamic
      final dynamic response = await supabaseClient
          .rpc('email_exists', params: {'email_param': email})
          .single();

      // Convertir explícitamente a bool (la función devuelve true/false)
      final bool emailExists = response as bool;

      return emailExists
          ? Left(AuthFailure(message: "El correo ya está registrado"))
          : const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: "Error validando email: $e"));
    }
  }

}