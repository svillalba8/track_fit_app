import 'package:flutter/material.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/features/profile/edit_user_page.dart';

class UserSettingsPage extends StatelessWidget {
  final UsuarioModel usuario;

  const UserSettingsPage({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
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
          // Aquí puedes ir agregando más opciones, como:
          // - Cambiar contraseña
          // - Notificaciones
          // - Cerrar sesión
        ],
      ),
    );
  }
}
