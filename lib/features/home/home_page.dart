import 'package:flutter/material.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<UsuarioModel?> _fetchUsuario() async {
    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    final usuarioService = getIt<UsuarioService>();
    return await usuarioService.fetchUsuarioByAuthId(authUser.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UsuarioModel?>(
      future: _fetchUsuario(),
      builder: (context, snapshot) {
        final usuario = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Cargando...'
                  : usuario != null
                  ? 'Hola, ${usuario.nombreUsuario}'
                  : 'Hola',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () async {
                  final supabase = getIt<SupabaseClient>();
                  await supabase.auth.signOut();
                },
              ),
            ],
          ),
          body: const Center(child: Text('Bienvenido a tu app')),
        );
      },
    );
  }
}
