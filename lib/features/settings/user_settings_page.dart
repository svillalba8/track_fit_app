import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

/// Página de ajustes de usuario:
/// - Permite editar datos, cambiar tema y cerrar sesión
class UserSettingsPage extends StatelessWidget {
  final UsuarioModel usuario;

  const UserSettingsPage({super.key, required this.usuario});

  /// Muestra diálogo de confirmación para cerrar sesión
  Future<void> _confirmLogout(BuildContext context) async {
    final actualTheme = Theme.of(context);

    // 1) Diálogo "¿Cerrar sesión?"
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cerrar sesión'),
            content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
            actions: [
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: CustomButton(
                      text: 'Volver',
                      actualTheme: actualTheme,
                      onPressed: () => context.pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.loose,
                    child: CustomButton(
                      text: 'Salir',
                      actualTheme: actualTheme,
                      onPressed: () => context.pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );

    // 2) Si confirma, cierra sesión en Supabase y navega a login
    if (shouldLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          // Opción: editar datos personales
          ListTile(
            leading: Icon(
              Icons.person,
              color: theme.colorScheme.secondaryFixed,
            ),
            title: Text(
              'Datos personales',
              style: TextStyle(color: theme.colorScheme.secondaryFixed),
            ),
            onTap: () async {
              // Navega a EditUser y, si hay usuario actualizado, retorna al previo
              final updated = await context.push<UsuarioModel>(
                AppRoutes.editUser,
                extra: usuario,
              );
              if (updated != null && context.mounted) {
                context.pop(updated);
              }
            },
          ),

          const SizedBox(height: 24),

          // Opción: cambiar tema
          ListTile(
            leading: Icon(
              Icons.color_lens,
              color: theme.colorScheme.secondaryFixed,
            ),
            title: Text(
              'Cambiar tema',
              style: TextStyle(color: theme.colorScheme.secondaryFixed),
            ),
            onTap: () => context.push(AppRoutes.themeSelector),
          ),

          const SizedBox(height: 24),

          // Separador y opción: cerrar sesión
          Divider(color: Colors.red.withAlpha(128), height: 0.1),
          Container(
            color: Colors.red.withAlpha(25),
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _confirmLogout(context), // Lanza confirmación
            ),
          ),
          Divider(color: Colors.red.withAlpha(128), height: 0.1),
        ],
      ),
    );
  }
}
