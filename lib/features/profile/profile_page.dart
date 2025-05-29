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
    const sombraCard = 8.0;

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

            //Tarjeta de Usuario
            Card(
              elevation: sombraCard,
              color: actualTheme.colorScheme.primary,
              shadowColor: Colors.black.withAlpha(255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
                    //Avatar de usuario
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: actualTheme.colorScheme.secondary
                              .withOpacity(0.3),
                          child: Text(
                            usuario!.nombreUsuario[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              color: actualTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario!.nombreUsuario,
                                style: actualTheme.textTheme.headlineMedium
                                    ?.copyWith(
                                      color: actualTheme.colorScheme.secondary,
                                    ),
                              ),
                              if (usuario!.descripcion != null &&
                                  usuario!.descripcion!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    usuario!.descripcion!,
                                    style: actualTheme.textTheme.bodyLarge
                                        ?.copyWith(
                                          color:
                                              actualTheme.colorScheme.secondary,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            //Tarjeta de objetivo
            Card(
              elevation: sombraCard,
              color: actualTheme.colorScheme.primaryContainer,
              shadowColor: Colors.black.withAlpha(255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/objetivo.png',
                          width: 28,
                          height: 28,
                          color: actualTheme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tu objetivo actual',
                          style: actualTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: actualTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (progreso?.objetivoPeso != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta de peso: ${progreso!.objetivoPeso} kg',
                            style: actualTheme.textTheme.bodyLarge,
                          ),

                          const SizedBox(height: 12),

                          _buildProgressBar(context, progreso!, usuario!),

                          const SizedBox(height: 12),

                          Center(
                            child: CustomButton(
                              text: 'Actualizar objetivo',
                              actualTheme: actualTheme,
                              onPressed: () {
                                // Aquí puedes navegar a una pantalla de edición de objetivo
                              },
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No has establecido un objetivo aún.',
                            style: actualTheme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: CustomButton(
                              text: 'Establecer objetivo',
                              actualTheme: actualTheme,
                              onPressed: () {
                                // Aquí también puedes abrir una pantalla para establecer objetivo
                              },
                            ),
                          ),
                        ],
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

Widget _buildProgressBar(
  BuildContext context,
  ProgresoModel progreso,
  UsuarioModel usuario,
) {
  double progresoValor = 0.0;

  final DateTime ahora = DateTime.now();

  if (progreso.fechaObjetivo != null) {
    final DateTime inicio = progreso.fechaComienzo;
    final DateTime fin = progreso.fechaObjetivo!;

    if (ahora.isBefore(inicio)) {
      progresoValor = 0.0;
    } else if (ahora.isAfter(fin)) {
      progresoValor = 1.0;
    } else {
      final totalDuracion = fin.difference(inicio).inDays;
      final transcurrido = ahora.difference(inicio).inDays;
      progresoValor = (transcurrido / totalDuracion).clamp(0.0, 1.0);
    }
  }

  // Color dinámico basado en el progreso
  Color getProgressColor() {
    if (progresoValor < 0.33) return Colors.red;
    if (progresoValor < 0.66) return Colors.amber;
    return Colors.green;
  }

  // Mensaje motivacional
  String getProgressMessage() {
    if (progresoValor == 1.0) return '¡Objetivo alcanzado!';
    if (progresoValor >= 0.66) return '¡Ya casi lo logras!';
    if (progresoValor >= 0.33) return '¡Sigue así!';
    return '¡Acabas de comenzar!';
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LinearProgressIndicator(
        value: progresoValor,
        minHeight: 10,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
        borderRadius: BorderRadius.circular(8),
      ),
      const SizedBox(height: 6),
      Text(
        '${(progresoValor * 100).toStringAsFixed(1)}% del tiempo transcurrido',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      Text(
        getProgressMessage(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: getProgressColor(),
        ),
      ),
    ],
  );
}
