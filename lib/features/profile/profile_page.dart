import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/api_service.dart';
import 'package:track_fit_app/features/profile/edit_user_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  late final ApiService apiService;
  UsuarioModel? usuario;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(supabase);
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
      appBar: AppBar(title: const Text('Perfil')),
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
            // Título sección
            Text('Información', style: theme.textTheme.titleMedium),
            const Divider(),
            // Menú de opciones
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Datos personales'),
              onTap: () async {
                final updatedUsuario = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditUserPage(usuario: usuario!),
                  ),
                );
                // Si volvemos con datos actualizados, los aplicamos al estado
                if (updatedUsuario != null && updatedUsuario is UsuarioModel) {
                  setState(() {
                    usuario = updatedUsuario;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Datos actualizados')),
                  );
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.show_chart),
              title: const Text('Progreso'),
              onTap: () {
                // Navegar a pantalla de progreso (por implementar)
              },
            ),
          ],
        ),
      ),
    );
  }
}
