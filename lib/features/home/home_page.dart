import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/home/widgets/home_card.dart';
import 'package:track_fit_app/features/home/widgets/hydration_widget.dart';
import 'package:track_fit_app/features/trainer/service/daily_challenge_dialog.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/models/routines_models/routine_model.dart'; // Asegúrate de tener este modelo
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';
import 'package:track_fit_app/notifiers/recipe_notifier.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/services/routines_services/routine_service.dart'; // Servicio para rutinas
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/features/routines/routine_page.dart'; // Ajusta según tu estructura

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final RoutineService _routineService = RoutineService();

  Routine? _rutinaRandom;
  bool _cargandoRutina = true;
  String? _errorRutina;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Inicializaciones previas
    context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
    context.read<RecipeNotifier>().initTodayRecipe();

    // Cargar rutina aleatoria
    _cargarRutinaRandom();
  }

  Future<void> _cargarRutinaRandom() async {
    setState(() {
      _cargandoRutina = true;
      _errorRutina = null;
    });

    try {
      final rutinas = await _routineService.getRoutines();
      if (rutinas.isEmpty) {
        setState(() {
          _rutinaRandom = null;
          _errorRutina = 'No tienes rutinas creadas.';
          _cargandoRutina = false;
        });
        return;
      }
      final rng = Random();
      setState(() {
        _rutinaRandom = rutinas[rng.nextInt(rutinas.length)];
        _cargandoRutina = false;
      });
    } catch (e) {
      setState(() {
        _errorRutina = 'Error al cargar rutina: $e';
        _cargandoRutina = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    return FutureBuilder<UsuarioModel?>(
      future: _fetchUsuario(),
      builder: (context, snapshot) {
        final usuario = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Cargando...'
                  : usuario != null
                  ? 'Bienvenido, ${usuario.nombreUsuario}'
                  : 'Bienvenido',
            ),
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.87,
              children: [
                // Card 1: Rutina random del usuario
                HomeCard(
                  icon: Icons.fitness_center,
                  title: _cargandoRutina
                      ? 'Cargando rutina...'
                      : _rutinaRandom?.nombre ?? 'Sin rutinas',
                  subtitle: _cargandoRutina
                      ? null
                      : _errorRutina ?? 'Pulsa para ver la rutina',
                  backgroundColor: const Color(0xFFF9F9FC),
                  onTap: (_cargandoRutina || _rutinaRandom == null)
                      ? () {}
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoutinePage(),
                      ),
                    );
                  },

                ),

                // Card 2: Reto del día
                HomeCard(
                  icon: Icons.emoji_events,
                  title: 'Reto diario',
                  subtitle: 'Completa el reto diario de hoy.',
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget: Consumer<DailyChallengeNotifier>(
                    builder: (_, retoProv, __) {
                      final completado = retoProv.retoCompletado;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: completado
                              ? Colors.green.shade100
                              : const Color(0xFFFCD34D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completado ? 'Completado' : 'En progreso',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: completado
                                ? Colors.green.shade800
                                : const Color(0xFF1C1C1E),
                          ),
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    DailyChallengeDialog.show(context);
                  },
                ),

                // Card 3: Racha
                HomeCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Racha',
                  subtitle: 'Un contador con tus días entrenados',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: null,
                  onTap: () {
                    // Navigator.pushNamed(context, '/racha');
                  },
                ),

                // Card 4: Mi progreso
                HomeCard(
                  icon: Icons.bar_chart,
                  title: 'Mi objetivo',
                  subtitle: '🔥 1.200 kcal\n 🏃‍♂️ 3 de 5 sesiones',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '🏃‍♂️ Sesiones completadas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0x993C3C43),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '3 de 5',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.pushNamed(context, '/miProgreso');
                  },
                ),

                // Card 5: Hidratación diaria
                HomeCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Agua diaria',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: HydrationWidget(),
                  onTap: () {},
                ),

                // Card 6: Recomendación alimentaria
                Consumer<RecipeNotifier>(
                  builder: (_, prov, __) {
                    Widget content;

                    if (prov.isLoading) {
                      content = const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Cargando receta…'),
                      );
                    } else if (prov.error != null) {
                      content = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Error: ${prov.error}'),
                      );
                    } else if (prov.titulo != null) {
                      content = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prov.titulo!,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: actualTheme.colorScheme.tertiary),
                          ),
                          const SizedBox(height: 20),
                          CustomDivider(color: actualTheme.colorScheme.tertiary),
                          const SizedBox(height: 4),
                          if (prov.calorias != null && prov.tiempoPreparacion != null)
                            Text(
                              '${prov.calorias} kcal · ${prov.tiempoPreparacion} min',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: actualTheme.colorScheme.tertiary),
                            ),
                        ],
                      );
                    } else {
                      content = const SizedBox();
                    }

                    return HomeCard(
                      icon: Icons.fastfood_rounded,
                      title: 'Nutrición',
                      subtitle: null,
                      backgroundColor: const Color(0xFFF2F2F7),
                      bottomWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: content,
                      ),
                      onTap: () {
                        // Navegar a detalle si quieres
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<UsuarioModel?> _fetchUsuario() async {
  final supabase = getIt<SupabaseClient>();
  final authUser = supabase.auth.currentUser;
  if (authUser == null) return null;

  final usuarioService = getIt<UsuarioService>();
  return await usuarioService.fetchUsuarioByAuthId(authUser.id);
}
