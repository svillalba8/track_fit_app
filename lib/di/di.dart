import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/usuario_service.dart'; // Asegúrate de tener esto
// import '../repositories/user_repository.dart'; // Cuando lo tengas

final getIt = GetIt.instance;

void setupDependencies() {
  // Registro del cliente de Supabase
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // Registro de ApiService con Supabase
  getIt.registerSingleton<ApiService>(ApiService(getIt<SupabaseClient>()));

  // Registro de repositorios u otros servicios (opcional)
  // getIt.registerSingleton<UserRepository>(
  //   UserRepository(getIt<ApiService>())
  // );
}
