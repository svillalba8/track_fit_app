import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class UserSettingsPage extends StatelessWidget {
  final UsuarioModel usuario;

  const UserSettingsPage({super.key, required this.usuario});

  Future<void> _confirmLogout(BuildContext context) async {
  final ThemeData actualTheme = Theme.of(context);

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              CustomButton(
                text: 'Cancelar',
                actualTheme: actualTheme,
                onPressed: () => context.pop(false),
              ),
              CustomButton(
                text: 'Cerrar sesión',
                actualTheme: actualTheme,
                onPressed: () => context.pop(true),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        // Navegar fuera del stack, al login
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

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
            leading: Icon(
              Icons.person,
              color: actualTheme.colorScheme.secondaryFixed,
            ),
            title: Text(
              'Datos personales',
              style: TextStyle(color: actualTheme.colorScheme.secondaryFixed),
            ),
            onTap: () async {
              final updatedUsuario = await context.push<UsuarioModel>(
                AppRoutes.editUser,
                extra: usuario,
              );
              if (updatedUsuario != null) {
                if (!context.mounted) return;
                context.pop(updatedUsuario);
              }
            },
          ),

          const SizedBox(height: 24), // separación visual

          ListTile(
            leading: Icon(
              Icons.color_lens,
              color: actualTheme.colorScheme.secondaryFixed,
            ),
            title: Text(
              'Cambiar tema',
              style: TextStyle(color: actualTheme.colorScheme.secondaryFixed),
            ),
            onTap: () {
              context.push(AppRoutes.themeSelector);
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
