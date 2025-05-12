import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/usuario.dart';

abstract class UsuarioSource {
  Future<Usuario?> getUserById(String id);
  Future<void> createUser(Usuario user);
  Future<void> updateUser(Usuario user);
  Future<void> deleteUser(String id);
}


class UsuarioSourceImpl implements UsuarioSource {
  final supabase.SupabaseClient supabaseClient = supabase.Supabase.instance.client;

  @override
  Future<Usuario?> getUserById(String id) async {
    final response = await supabaseClient
        .from('usuarios')
        .select()
        .eq('auth_user_id', id)
        .maybeSingle();

    return response != null ? Usuario.fromJson(response) : null;
  }

  @override
  Future<void> createUser(Usuario user) async {
    await supabaseClient.from('usuarios').insert(user.toJson());
  }

  @override
  Future<void> updateUser(Usuario user) async {
    await supabaseClient
        .from('usuarios')
        .update(user.toJson())
        .eq('auth_user_id', user.authUserId);
  }

  @override
  Future<void> deleteUser(String id) async {
    await supabaseClient.from('usuarios').delete().eq('auth_user_id', id);
  }
}
