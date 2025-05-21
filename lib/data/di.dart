import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/usuario_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerSingleton<UsuarioService>(
    UsuarioService(getIt<SupabaseClient>()),
  );
}
