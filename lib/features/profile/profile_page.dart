import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart';
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
    final actualTheme = Theme.of(context);
    const grosorCard = 0.5;
    const sombraCard = 20.0;

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
              color: actualTheme.colorScheme.secondary,
            ),
            onPressed: () async {
              final updatedUsuario = await context.push<UsuarioModel>(
                AppRoutes.settings,
                extra: usuario,
              );
              if (updatedUsuario != null) {
                setState(() {
                  usuario = updatedUsuario;
                });
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Card(
              elevation: sombraCard,
              color: actualTheme.colorScheme.primary,
              shadowColor: Colors.black.withAlpha(255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: actualTheme.colorScheme.secondary,
                  width: grosorCard,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Usuario y descripción
                    Text(
                      usuario!.nombreUsuario,
                      style: actualTheme.textTheme.headlineMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                    ),
                    if (usuario!.descripcion != null &&
                        usuario!.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          usuario!.descripcion!,
                          style: actualTheme.textTheme.bodyLarge?.copyWith(
                            color: actualTheme.colorScheme.secondary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),
                    Divider(
                      color: actualTheme.colorScheme.secondary,
                      thickness: 0.1,
                    ),

                    // Información física
                    const SizedBox(height: 12),
                    _infoRow(
                      'assets/icons/peso_kg.png',
                      'Peso',
                      '${usuario!.peso} kg',
                    ),
                    _infoRow(
                      'assets/icons/estatura.png',
                      'Estatura',
                      '${usuario!.estatura} cm',
                    ),
                    _infoRow(
                      'assets/icons/generos.png',
                      'Género',
                      usuario!.genero,
                    ),
                    _infoRow(
                      'assets/icons/objetivo.png',
                      'Peso Objetivo',
                      '${progreso?.objetivoPeso ?? 'No establecido'}',
                    ),

                    const SizedBox(height: 24),

                    // Botón de editar
                    Align(
                      alignment: Alignment.center,
                      child: CustomButton(
                        text: 'Comenzar Objetivo',
                        actualTheme: actualTheme,
                        onPressed: () async {},
                      ),
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

  Widget _infoRow(String iconString, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Image.asset(
            iconString,
            width: 24,
            height: 24,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
