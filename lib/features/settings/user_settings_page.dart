import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/features/profile/edit_user_page.dart';

class UserSettingsPage extends StatelessWidget {
  final UsuarioModel usuario;

  const UserSettingsPage({super.key, required this.usuario});

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // Navegar fuera del stack, por ejemplo al login
        context.go('/login'); // Asegúrate de tener esta ruta
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Datos personales'),
            onTap: () async {
              final updatedUsuario = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditUserPage(usuario: usuario),
                ),
              );
              if (updatedUsuario != null && updatedUsuario is UsuarioModel) {
                Navigator.pop(context, updatedUsuario);
              }
            },
          ),
          const SizedBox(height: 24), // separación visual
          Divider(color: Colors.red.withValues(alpha: 0.5), height: 0.1),
          Container(
            color: Colors.red.withValues(alpha: 0.10),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmLogout(context),
            ),
          ),
          Divider(color: Colors.red.withValues(alpha: 0.5), height: 0.1),
        ],
      ),
    );
  }
}
