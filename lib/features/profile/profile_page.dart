import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

        setState(() {
          usuario = dataUsuario;
        });

        if (dataUsuario != null && dataUsuario.idProgreso != null) {
          try {
            dataProgreso = await progresoService.fetchProgresoById(
              dataUsuario.idProgreso!,
            );
          } catch (e) {
            print("Error al cargar progreso: $e");
          }
        }

        setState(() {
          progreso = dataProgreso;
          isLoading = false;
        });
      } catch (e) {
        print("Error al cargar usuario: $e");
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
        elevation: 0,
        backgroundColor: actualTheme.colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        titleSpacing: 24,
        title: Text(
          'Perfil',
          style: actualTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: actualTheme.colorScheme.secondary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                final updatedUsuario = await context.push<UsuarioModel>(
                  AppRoutes.settings,
                  extra: usuario,
                );
                if (updatedUsuario != null) {
                  await _loadUsuarioYProgreso();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: actualTheme.colorScheme.secondary.withOpacity(0.12),
                ),
                child: Image.asset(
                  'assets/icons/engranaje_ajustes.png',
                  width: 22,
                  height: 22,
                  color: actualTheme.colorScheme.secondary,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Tarjeta de Usuario mejorada visualmente
            Card(
              elevation: sombraCard,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      actualTheme.colorScheme.primary.withOpacity(0.9),
                      actualTheme.colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: actualTheme.colorScheme.secondary.withOpacity(0.4),
                    width: grosorCard,
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar y nombre de usuario
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: actualTheme.colorScheme.secondary
                              .withOpacity(0.15),
                          child: CircleAvatar(
                            radius: 34,
                            backgroundColor: actualTheme.colorScheme.primary,
                            child: Text(
                              usuario!.nombreUsuario[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                color: actualTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                usuario!.nombreUsuario,
                                style: actualTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                      color: actualTheme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (usuario!.descripcion != null &&
                                  usuario!.descripcion!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    usuario!.descripcion!,
                                    style: actualTheme.textTheme.bodyMedium
                                        ?.copyWith(
                                          color: actualTheme
                                              .colorScheme
                                              .onPrimary
                                              .withOpacity(0.85),
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
                      color: actualTheme.colorScheme.onPrimary.withOpacity(0.3),
                      thickness: 0.3,
                    ),

                    const SizedBox(height: 16),

                    // Información física
                    Wrap(
                      runSpacing: 12,
                      children: [
                        _infoRowModern(
                          iconPath: 'assets/icons/peso_kg.png',
                          label: 'Peso',
                          value: '${usuario!.peso} kg',
                          theme: actualTheme,
                        ),
                        _infoRowModern(
                          iconPath: 'assets/icons/estatura.png',
                          label: 'Estatura',
                          value: '${usuario!.estatura} cm',
                          theme: actualTheme,
                        ),
                        _infoRowModern(
                          iconPath: 'assets/icons/generos.png',
                          label: 'Género',
                          value: usuario!.genero,
                          theme: actualTheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tarjeta de Objetivo Mejorada
            Card(
              elevation: sombraCard,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [
                      actualTheme.colorScheme.primaryContainer.withOpacity(0.9),
                      actualTheme.colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: actualTheme.colorScheme.secondary.withOpacity(0.4),
                    width: grosorCard,
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e icono
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: actualTheme.colorScheme.secondary
                              .withOpacity(0.15),
                          child: Image.asset(
                            'assets/icons/objetivo.png',
                            width: 20,
                            height: 20,
                            color: actualTheme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Tu objetivo actual',
                          style: actualTheme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: actualTheme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (progreso?.objetivoPeso != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta de peso: ${progreso!.objetivoPeso} kg',
                            style: actualTheme.textTheme.bodyLarge?.copyWith(
                              color: actualTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProgressBar(context, progreso!, usuario!),
                          const SizedBox(height: 20),
                          Center(
                            child: CustomButton(
                              text: 'Actualizar objetivo',
                              actualTheme: actualTheme,
                              onPressed: () async {
                                final nuevoProgreso = await context
                                    .push<ProgresoModel?>(
                                      AppRoutes.goal,
                                      extra: progreso,
                                    );
                                if (nuevoProgreso != null) {
                                  await _loadUsuarioYProgreso();
                                }
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
                            style: actualTheme.textTheme.bodyLarge?.copyWith(
                              color: actualTheme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: CustomButton(
                              text: 'Establecer objetivo',
                              actualTheme: actualTheme,
                              onPressed: () async {
                                final nuevoProgreso = await context
                                    .push<ProgresoModel?>(
                                      AppRoutes.goal,
                                      extra: null,
                                    );
                                if (nuevoProgreso != null) {
                                  await _loadUsuarioYProgreso();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRowModern({
    required String iconPath,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
          child: Image.asset(
            iconPath,
            width: 18,
            height: 18,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    ProgresoModel progreso,
    UsuarioModel usuario,
  ) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final ahora = DateTime.now();
    double progresoTiempo = 0.0;

    if (progreso.fechaObjetivo != null) {
      final inicio = progreso.fechaComienzo;
      final fin = progreso.fechaObjetivo!;
      if (ahora.isBefore(inicio)) {
        progresoTiempo = 0.0;
      } else if (ahora.isAfter(fin)) {
        progresoTiempo = 1.0;
      } else {
        final totalDias = fin.difference(inicio).inDays;
        final diasTranscurridos = ahora.difference(inicio).inDays;
        if (totalDias > 0) {
          progresoTiempo = (diasTranscurridos / totalDias).clamp(0.0, 1.0);
        }
      }
    }

    final pesoInicial = progreso.pesoInicial;
    final pesoActual = usuario.peso;
    final pesoObjetivo = progreso.objetivoPeso;

    double progresoPeso = 0.0;

    if (pesoObjetivo != null) {
      if (pesoInicial == pesoObjetivo) {
        progresoPeso = 1.0;
      } else if (pesoInicial > pesoObjetivo) {
        progresoPeso =
            (pesoInicial - pesoActual) / (pesoInicial - pesoObjetivo);
      } else {
        progresoPeso =
            (pesoActual - pesoInicial) / (pesoObjetivo - pesoInicial);
      }
      progresoPeso = progresoPeso.clamp(0.0, 1.0);
    }

    String getMensaje(double value, String tipo) {
      if (value == 1.0) {
        return tipo == 'físico'
            ? '¡Peso objetivo alcanzado!'
            : '¡Tiempo completado!';
      } else if (value >= 0.66) {
        return '¡Ya casi lo logras!';
      } else if (value >= 0.33) {
        return '¡Buen progreso!';
      } else {
        return '¡Acabas de empezar!';
      }
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso físico: ${((progresoPeso) * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: progresoPeso,
            minHeight: 14,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.secondary,
            ),
          ),
        ),

        const SizedBox(height: 4),
        Text(
          getMensaje(progresoPeso, 'físico'),
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 16),

        Text(
          'Progreso temporal: ${((progresoTiempo) * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: progresoTiempo,
            minHeight: 14,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.secondary,
            ),
          ),
        ),

        const SizedBox(height: 4),
        Text(
          getMensaje(progresoTiempo, 'temporal'),
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 8),

        //Fecha inicio y fecha objetivo
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de inicio:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(progreso.fechaComienzo),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha objetivo:',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progreso.fechaObjetivo != null
                          ? dateFormatter.format(progreso.fechaObjetivo!)
                          : 'Sin fecha',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
