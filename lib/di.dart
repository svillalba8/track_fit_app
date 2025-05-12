import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/blocs/auth_bloc.dart';
import 'package:track_fit_app/repositories/auth_repository.dart';
import 'package:track_fit_app/repositories/auth_repository_impl.dart';
import 'package:track_fit_app/sources/auth_source.dart';
import 'package:track_fit_app/sources/usuario_source.dart';
import 'package:track_fit_app/use_cases/cerrar_sesion_usecase.dart';
import 'package:track_fit_app/use_cases/get_current_user_usecase.dart';
import 'package:track_fit_app/use_cases/login_usecase.dart';
import 'package:track_fit_app/use_cases/register_usecase.dart';

final GetIt di = GetIt.instance;

Future<void> setupDependencies() async {
  try {
    // 1. Carga de variables de entorno con validación
    await _loadEnvConfig();

    // 2. Inicialización de Supabase con validación
    await _initializeSupabase();

    // 3. Registro de dependencias
    _registerDependencies();

  } catch (e) {
    print('Error crítico al configurar dependencias: $e');
    rethrow;
  }
}

Future<void> _loadEnvConfig() async {
  try {
    await dotenv.load(fileName: '.env');

    // Validar variables requeridas
    final requiredVars = ['SUPABASE_URL', 'SUPABASE_KEY'];
    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        throw Exception('Variable $varName no encontrada en .env');
      }
    }
  } catch (e) {
    throw Exception('Error cargando configuración .env: $e');
  }
}

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_KEY']!,
    );
  } catch (e) {
    throw Exception('Error inicializando Supabase: $e');
  }
}

void _registerDependencies() {
  // Fuentes de datos
  di.registerLazySingleton<AuthSource>(() => AuthSourceImpl());
  di.registerLazySingleton<UsuarioSource>(() => UsuarioSourceImpl());

  // Repositorios
  di.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    authSource: di(),
    usuarioSource: di(),
  ));

  // Casos de uso
  di.registerLazySingleton(() => LoginUseCase(repository: di()));
  di.registerLazySingleton(() => RegisterUseCase(repository: di()));
  di.registerLazySingleton(() => CerrarSesionUseCase(repository: di()));
  di.registerLazySingleton(() => GetCurrentUserUseCase(repository: di()));

  // BLoCs
  di.registerFactory(() => AuthBloc(
    di(),
    di(),
    di(),
    di(),
  ));
}

// Para testing/reset
void resetDependencies() {
  di.reset();
}