import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/usuario_model.dart';

class UsuarioService {
  final SupabaseClient supabase;

  UsuarioService(this.supabase);

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
}
