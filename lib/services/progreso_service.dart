import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/progreso_model.dart';

class ProgresoService {
  // Cliente Supabase inyectado para operaciones en la base de datos
  final SupabaseClient supabase;

  ProgresoService(this.supabase);

  /// Recupera un progreso por su ID (puede devolver null si no existe)
  Future<ProgresoModel?> fetchProgresoById(int idProgreso) async {
    final response =
        await supabase
            .from('progreso')
            .select()
            .eq('id', idProgreso)
            .maybeSingle();

    if (response == null) return null;

    return ProgresoModel.fromJson(response);
  }

  /// Crea un nuevo progreso con objetivo y fecha, y actualiza al usuario actual
  Future<ProgresoModel> createProgreso({
    required double objetivoPeso,
    required double pesoInicial,
    required DateTime? fechaObjetivo,
  }) async {
    final nowIso = DateTime.now().toIso8601String();

    final progResponse =
        await supabase
            .from('progreso')
            .insert({
              'objetivo_peso': objetivoPeso,
              'peso_inicial': pesoInicial,
              'fecha_comienzo': nowIso,
              'fecha_objetivo': fechaObjetivo?.toIso8601String(),
            })
            .select()
            .single();

    final nuevoProgreso = ProgresoModel.fromJson(progResponse);

    // Asocia el nuevo progreso al usuario autenticado
    final authUser = supabase.auth.currentUser;
    if (authUser != null) {
      await supabase
          .from('usuarios')
          .update({'id_progreso': nuevoProgreso.id})
          .eq('auth_user_id', authUser.id);
    }

    return nuevoProgreso;
  }

  /// Actualiza los campos de un progreso existente
  Future<ProgresoModel> updateProgreso(ProgresoModel progreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({
              'objetivo_peso': progreso.objetivoPeso,
              'peso_inicial': progreso.pesoInicial,
              'fecha_objetivo': progreso.fechaObjetivo?.toIso8601String(),
            })
            .eq('id', progreso.id)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }

  /// Cancela el objetivo de peso limpiando esos campos en el progreso
  Future<ProgresoModel> cancelarObjetivo(int idProgreso) async {
    final response =
        await supabase
            .from('progreso')
            .update({'objetivo_peso': null, 'fecha_objetivo': null})
            .eq('id', idProgreso)
            .select()
            .single();

    return ProgresoModel.fromJson(response);
  }

  /// Actualiza solo el peso del usuario autenticado en la tabla de usuarios
  Future<void> updatePesoUsuario(double nuevoPeso) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    await supabase
        .from('usuarios')
        .update({'peso': nuevoPeso})
        .eq('auth_user_id', authUser.id);
  }
}
