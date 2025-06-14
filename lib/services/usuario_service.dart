import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/usuario_model.dart';

class UsuarioService {
  // Cliente Supabase inyectado para acceder a la BD
  final SupabaseClient supabase;

  UsuarioService(this.supabase);

  /// Recupera un usuario según su `auth_user_id`
  /// - Realiza un SELECT en la tabla 'usuarios'
  /// - Devuelve un `UsuarioModel` o null si no existe
  Future<UsuarioModel?> fetchUsuarioByAuthId(String authUserId) async {
    final response =
        await supabase
            .from('usuarios')
            .select()
            .eq('auth_user_id', authUserId)
            .maybeSingle();

    if (response != null) {
      return UsuarioModel.fromJson(response);
    }
    return null;
  }

  /// Actualiza todos los campos editables de un usuario
  /// - Construye un mapa con los datos modificados
  /// - Ejecuta un UPDATE y lanza excepción si falla
  Future<void> updateUsuario(UsuarioModel usuario) async {
    final updateData = {
      'nombre_usuario': usuario.nombreUsuario,
      'descripcion': usuario.descripcion,
      'peso': usuario.peso,
      'estatura': usuario.estatura,
      'updated_at': DateTime.now().toIso8601String(),
      if (usuario.idProgreso != null) 'id_progreso': usuario.idProgreso,
    };

    final response =
        await supabase
            .from('usuarios')
            .update(updateData)
            .eq('auth_user_id', usuario.authUsersId)
            .select()
            .maybeSingle();

    if (response == null) {
      throw Exception('No se pudo actualizar el usuario');
    }
  }

  /// Solo actualiza el peso del usuario actualmente autenticado
  Future<void> updatePesoUsuario(double nuevoPeso) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    await supabase
        .from('usuarios')
        .update({'peso': nuevoPeso})
        .eq('auth_user_id', authUser.id);
  }
}
