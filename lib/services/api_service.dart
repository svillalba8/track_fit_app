import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/UsuarioModel.dart';

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
}
