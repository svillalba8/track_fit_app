import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/features/settings/user_settings_page.dart'; // <-- nueva pantalla

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  late final UsuarioService apiService;
  UsuarioModel? usuario;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService = UsuarioService(supabase);
    _loadUsuario();
  }

  Future<void> _loadUsuario() async {
    final authUserId = supabase.auth.currentUser?.id;
    if (authUserId != null) {
      final data = await apiService.fetchUsuarioByAuthId(authUserId);
      setState(() {
        usuario = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: Text('No se pudo cargar el usuario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final updatedUsuario = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserSettingsPage(usuario: usuario!),
                ),
              );
              if (updatedUsuario != null && updatedUsuario is UsuarioModel) {
                setState(() {
                  usuario = updatedUsuario;
                });
                showNeutralSnackBar(context, 'Datos actualizados');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre de usuario
            Text(usuario!.nombreUsuario, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),

            // Descripción
            Text(
              usuario!.descripcion ?? 'Sin descripción',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),
            Text('Datos del usuario', style: theme.textTheme.titleMedium),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.monitor_weight),
              title: const Text('Peso actual'),
              trailing: Text('${usuario!.peso} kg'),
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Objetivo de peso'),
            ),
          ],
        ),
      ),
    );
  }
}
