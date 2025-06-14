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
    _loadUsuarioYProgreso(); // Carga inicial de usuario y progreso al iniciar
  }

  /// 1) Obtiene el usuario autenticado y, si tiene, su progreso
  /// 2) Actualiza el estado para mostrar datos o errores
  Future<void> _loadUsuarioYProgreso() async {
    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;

    if (authUser != null) {
      try {
        final dataUsuario = await userService.fetchUsuarioByAuthId(authUser.id);
        ProgresoModel? dataProgreso;
        setState(() => usuario = dataUsuario);

        if (dataUsuario?.idProgreso != null) {
          // Si hay un objetivo, lo carga
          dataProgreso = await progresoService.fetchProgresoById(
            dataUsuario!.idProgreso!,
          );
        }

        setState(() {
          progreso = dataProgreso;
          isLoading = false;
        });
      } catch (e) {
        // Manejo de errores al cargar
        setState(() => isLoading = false);
        if (!mounted) return;
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

    if (isLoading) {
      // Indicador mientras carga
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (usuario == null) {
      // Mensaje si no se pudo obtener usuario
      return const Scaffold(
        body: Center(child: Text('No se pudo cargar el usuario')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Perfil',
          style: actualTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: actualTheme.colorScheme.secondary,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          // Botón para ir a ajustes (editar)
          IconButton(
            icon: Image.asset(
              'assets/icons/engranaje_ajustes.png',
              color: actualTheme.colorScheme.secondary,
            ),
            onPressed: () async {
              // Espera posible usuario actualizado al volver
              final updated = await context.push<UsuarioModel>(
                AppRoutes.settings,
                extra: usuario,
              );
              if (updated != null) _loadUsuarioYProgreso();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Tarjeta con avatar, nombre y descripción
            _buildUserCard(actualTheme),
            const SizedBox(height: 24),
            // Tarjeta de objetivo y progreso
            _buildGoalCard(actualTheme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta con datos básicos del usuario
  Widget _buildUserCard(ThemeData theme) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.9),
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar y nombre de usuario
            Row(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.15,
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      usuario!.nombreUsuario[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        color: theme.colorScheme.onPrimary,
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
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      if (usuario!.descripcion?.isNotEmpty == true)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            usuario!.descripcion!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary.withValues(
                                alpha: 0.85,
                              ),
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
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.3),
              thickness: 0.3,
            ),
            const SizedBox(height: 16),
            // Fila con peso, estatura y género
            Wrap(
              runSpacing: 12,
              children: [
                _infoRowModern(
                  iconPath: 'assets/icons/peso_kg.png',
                  label: 'Peso',
                  value: '${usuario!.peso} kg',
                  theme: theme,
                ),
                _infoRowModern(
                  iconPath: 'assets/icons/estatura.png',
                  label: 'Estatura',
                  value: '${usuario!.estatura} cm',
                  theme: theme,
                ),
                _infoRowModern(
                  iconPath: 'assets/icons/generos.png',
                  label: 'Género',
                  value: usuario!.genero,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta de objetivo actual y muestra progreso
  Widget _buildGoalCard(ThemeData theme) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título e icono de objetivo
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.secondary.withValues(
                    alpha: 0.15,
                  ),
                  child: Image.asset(
                    'assets/icons/objetivo.png',
                    width: 20,
                    height: 20,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tu objetivo actual',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (progreso?.objetivoPeso != null)
              // Si hay objetivo, muestra meta y barra de progreso
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meta de peso: ${progreso!.objetivoPeso} kg',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressBar(context, progreso!, usuario!),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      text: 'Actualizar objetivo',
                      actualTheme: theme,
                      onPressed: () async {
                        final nuevo = await context.push<ProgresoModel?>(
                          AppRoutes.goal,
                          extra: progreso,
                        );
                        if (nuevo != null) _loadUsuarioYProgreso();
                      },
                    ),
                  ),
                ],
              )
            else
              // Si no hay objetivo, invita a crear uno
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No has establecido un objetivo aún.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: CustomButton(
                      text: 'Establecer objetivo',
                      actualTheme: theme,
                      onPressed: () async {
                        final nuevo = await context.push<ProgresoModel?>(
                          AppRoutes.goal,
                          extra: null,
                        );
                        if (nuevo != null) _loadUsuarioYProgreso();
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Fila con icono y texto formateado
  Widget _infoRowModern({
    required String iconPath,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
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
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Calcula y muestra dos barras de progreso:
  /// - Progreso físico (peso actual vs objetivo)
  /// - Progreso temporal (días transcurridos vs total)
  Widget _buildProgressBar(
    BuildContext context,
    ProgresoModel progreso,
    UsuarioModel usuario,
  ) {
    final fmt = DateFormat('dd/MM/yyyy');
    final now = DateTime.now();

    // Cálculo de porcentaje de tiempo transcurrido
    double progresoTiempo = 0.0;
    if (progreso.fechaObjetivo != null) {
      final start = progreso.fechaComienzo;
      final end = progreso.fechaObjetivo!;
      if (now.isAfter(start)) {
        final totalDays = end.difference(start).inDays;
        final elapsed = now.difference(start).inDays;
        progresoTiempo =
            totalDays > 0 ? (elapsed / totalDays).clamp(0.0, 1.0) : 0.0;
      }
    }

    // Cálculo de porcentaje de peso alcanzado
    final initial = progreso.pesoInicial;
    final current = usuario.peso;
    final goal = progreso.objetivoPeso;
    double progresoPeso = 0.0;
    if (goal != null) {
      progresoPeso =
          (initial == goal)
              ? 1.0
              : initial > goal
              ? ((initial - current) / (initial - goal))
              : ((current - initial) / (goal - initial));
      progresoPeso = progresoPeso.clamp(0.0, 1.0);
    }

    String mensaje(double val) {
      if (val == 1.0) return '¡Objetivo alcanzado!';
      if (val >= 0.66) return '¡Ya casi lo logras!';
      if (val >= 0.33) return '¡Buen progreso!';
      return '¡Acabas de empezar!';
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso físico: ${(progresoPeso * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: progresoPeso,
            minHeight: 14,
            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
          ),
        ),
        const SizedBox(height: 4),
        Text(mensaje(progresoPeso), style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        Text(
          'Progreso temporal: ${(progresoTiempo * 100).toStringAsFixed(1)}%',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LinearProgressIndicator(
            value: progresoTiempo,
            minHeight: 14,
            backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.secondary),
          ),
        ),
        const SizedBox(height: 4),
        Text(mensaje(progresoTiempo), style: theme.textTheme.bodySmall),
        const SizedBox(height: 8),
        // Fechas de inicio y objetivo
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha de inicio:', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(progreso.fechaComienzo),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha objetivo:', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      progreso.fechaObjetivo != null
                          ? fmt.format(progreso.fechaObjetivo!)
                          : 'Sin fecha',
                      style: theme.textTheme.bodyMedium,
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
