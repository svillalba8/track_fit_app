import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/usuario_model.dart';

class ApiService {
  final SupabaseClient client;

  ApiService(this.client);

  Future<UsuarioModel?> fetchUsuarioByAuthId(String authUserId) async {
    final response =
        await client
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
    final response =
        await client
            .from('usuarios')
            .update({
              'nombre_usuario': usuario.nombreUsuario,
              'descripcion': usuario.descripcion,
              'peso': usuario.peso,
              'estatura': usuario.estatura,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('auth_user_id', usuario.authUsersId)
            .select()
            .maybeSingle();

    if (response == null) {
      throw Exception('No se pudo actualizar el usuario');
    }
  }
}
