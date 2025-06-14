import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/services/progreso_service.dart';
import '../services/usuario_service.dart';

final getIt = GetIt.instance; // Instancia global de GetIt

/// Registra las dependencias de la aplicación:
/// - Cliente Supabase
/// - Servicios de usuario y progreso
void setupDependencies() {
  // Registra el cliente Supabase como singleton
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);

  // Registra el servicio de usuario, inyectando el cliente Supabase
  getIt.registerSingleton<UsuarioService>(
    UsuarioService(getIt<SupabaseClient>()),
  );

  // Registra el servicio de progreso, inyectando el cliente Supabase
  getIt.registerSingleton<ProgresoService>(
    ProgresoService(getIt<SupabaseClient>()),
  );
}
