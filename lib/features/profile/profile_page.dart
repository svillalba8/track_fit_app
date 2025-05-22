import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/settings/user_settings_page.dart';
import 'package:track_fit_app/models/progreso_model.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/progreso_service.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final UsuarioService userService;
  late final ProgresoService progresoService;
  UsuarioModel? usuario;
  ProgresoModel? progreso;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userService = getIt<UsuarioService>();
    progresoService = ProgresoService(getIt<SupabaseClient>());
    _loadUsuarioYProgreso();
  }

  Future<void> _loadUsuarioYProgreso() async {
    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;

    if (authUser != null) {
      try {
        final dataUsuario = await userService.fetchUsuarioByAuthId(authUser.id);
        ProgresoModel? dataProgreso;

        if (dataUsuario != null && dataUsuario.idProgreso != null) {
          dataProgreso = await progresoService.fetchProgresoById(
            dataUsuario.idProgreso!,
          );
        }

        setState(() {
          usuario = dataUsuario;
          progreso = dataProgreso;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
        showErrorSnackBar(context, 'Error al cargar usuario o progreso');
      }
    } else {
      setState(() => isLoading = false);
      showErrorSnackBar(context, 'No hay usuario autenticado');
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
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/engranaje_ajustes.png',
              width: 26,
              height: 26,
              color: theme.colorScheme.secondary,
            ),
            onPressed: () async {
              final updatedUsuario = await context.push<UsuarioModel>(
                '/profile/edit-user',
                extra: usuario!,
              );
              if (updatedUsuario is UsuarioModel) {
                setState(() => usuario = updatedUsuario);
                showNeutralSnackBar(context, 'Datos actualizados');
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Usuario y descripción
                    Text(
                      usuario!.nombreUsuario,
                      style: theme.textTheme.headlineMedium,
                    ),
                    if (usuario!.descripcion != null &&
                        usuario!.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          usuario!.descripcion!,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),

                    const SizedBox(height: 24),
                    Divider(color: theme.dividerColor),

                    // Información física
                    const SizedBox(height: 12),
                    _infoRow('Peso', '${usuario!.peso} kg'),
                    _infoRow('Estatura', '${usuario!.estatura} cm'),
                    _infoRow('Género', usuario!.genero),
                    _infoRow(
                      'Peso Objetivo',
                      '${progreso?.objetivoPeso ?? 'No establecido'}',
                    ),

                    const SizedBox(height: 24),

                    // Botón de editar
                    CustomButton(
                      text: 'Comenzar Objetivo',
                      actualTheme: theme,
                      onPressed: () async {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
