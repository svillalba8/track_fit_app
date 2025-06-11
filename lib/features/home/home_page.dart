import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/home/widgets/ejercicios_page_view.dart';
import 'package:track_fit_app/features/home/widgets/home_card.dart';
import 'package:track_fit_app/features/home/widgets/hydration_widget.dart';
import 'package:track_fit_app/features/home/widgets/my_objective_widget.dart';
import 'package:track_fit_app/features/home/widgets/rutinas_dialog.dart';
import 'package:track_fit_app/features/trainer/service/daily_challenge_dialog.dart';
import 'package:track_fit_app/models/progreso_model.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';
import 'package:track_fit_app/notifiers/recipe_notifier.dart';
import 'package:track_fit_app/services/progreso_service.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import '../../widgets/custom_button.dart';
import '../routines/models/exercise_model.dart';
import '../routines/models/routine_model.dart';
import '../routines/services/exercise_service.dart';
import '../routines/services/routine_service.dart';
import '../routines/widgets/exercise_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final ProgresoService _progresoService;
  Future<ProgresoModel?>? _futProgreso;

  Routine? rutinaAleatoria;
  List<Exercise> ejercicios = [];
  bool isLoadingEjercicios = true;
  final ExerciseService exerciseService = ExerciseService();

  late final PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    _progresoService = ProgresoService(Supabase.instance.client);

    _cargarRutinaAleatoria();
    _cargarEjercicios();

    context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
    context.read<RecipeNotifier>().initTodayRecipe();
  }

  Future<void> _cargarRutinaAleatoria() async {
    final routineService = RoutineService();
    final rutinas = await routineService.getRoutines();
    if (rutinas.isNotEmpty) {
      final random = Random();
      setState(() {
        rutinaAleatoria = rutinas[random.nextInt(rutinas.length)];
      });
    }
  }

  Future<void> _cargarEjercicios() async {
    setState(() => isLoadingEjercicios = true);
    final exerciseService = ExerciseService();
    final listaEjercicios = await exerciseService.getExercises();
    setState(() {
      ejercicios = listaEjercicios;
      isLoadingEjercicios = false;
      _currentPageIndex = 0;
      _pageController.jumpToPage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_futProgreso == null) {
      final usuario = Provider.of<UsuarioModel?>(context);
      final idProg = usuario?.idProgreso;
      _futProgreso =
          (idProg != null)
              ? _progresoService.fetchProgresoById(idProg)
              : Future.value(null);
    }
  }

  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextPage() {
    if (_currentPageIndex < ejercicios.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    return FutureBuilder<UsuarioModel?>(
      future: _fetchUsuario(),
      builder: (context, snapshot) {
        // 1) Mientras está cargando, muestra un spinner completo
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) Si hubo error o no trajo usuario, mensaje
        if (snapshot.hasError || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('No se pudo cargar tu perfil')),
          );
        }

        // 3) Aquí ya tienes usuario NO nulo
        final usuario = snapshot.data!;

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
                // Card 1: Rutina aleatoria del usuario
                HomeCard(
                  icon: Icons.fitness_center,
                  title: rutinaAleatoria?.nombre ?? 'Cargando rutina...',
                  subtitle: null,
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget:
                      rutinaAleatoria != null
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                '¡Que la pereza no te pueda! ¿Ya has entrenado hoy?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0x993C3C43),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Builder(
                                  builder:
                                      (context) => TextButton(
                                        onPressed: () async {
                                          final routineService =
                                              RoutineService();
                                          final todasLasRutinas =
                                              await routineService
                                                  .getRoutines();

                                          if (!mounted) return;

                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return RutinasDialog(
                                                todasLasRutinas:
                                                    todasLasRutinas,
                                                onEntrenar: () {
                                                  if (rutinaAleatoria != null) {
                                                    context.push(
                                                      '/routines',
                                                      extra: rutinaAleatoria,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        },
                                        child: const Text('Ver rutinas'),
                                      ),
                                ),
                              ),
                            ],
                          )
                          : null,
                  onTap: () {}, // desactivado para usar solo el botón
                ),

                // Card 2: Reto diario
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
                          color:
                              completado
                                  ? Colors.green.shade100
                                  : const Color(0xFFFCD34D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completado ? 'Completado' : 'En progreso',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                completado
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

                // Card 3: Ejercicios con flechas para navegar y botón añadir
                HomeCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Estos son tus ejercicios, ¿añadimos alguno más?',
                  subtitle: null,
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      EjerciciosPageView(
                        isLoading: isLoadingEjercicios,
                        ejercicios: ejercicios,
                        pageController: _pageController,
                        initialPage: _currentPageIndex,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPageIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Añadir nuevo ejercicio',
                        actualTheme: actualTheme,
                        onPressed: () {
                          showExerciseForm(context, exerciseService, () {
                            _cargarEjercicios(); // recarga la lista tras guardar
                          });
                        },
                      ),
                    ],
                  ),
                  onTap:
                      () {}, // sin acción en la card para no interferir con el botón
                ),

                // Card 4: Mi objetivo
                FutureBuilder<ProgresoModel?>(
                  future:
                      usuario.idProgreso != null
                          ? _progresoService.fetchProgresoById(
                            usuario.idProgreso!,
                          )
                          : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return HomeCard(
                        icon: Icons.flag_rounded,
                        title: 'Mi Objetivo',
                        backgroundColor: const Color(0xFFF2F2F7),
                        bottomWidget: const Center(
                          child: CircularProgressIndicator(),
                        ),
                        onTap: () => context.push(AppRoutes.profile),
                      );
                    }
                    final prog = snapshot.data;
                    return HomeCard(
                      icon: Icons.flag_rounded,
                      title: 'Mi Objetivo',
                      backgroundColor: const Color(0xFFF2F2F7),
                      bottomWidget: ObjetivoPesoWidget(
                        pesoUsuario: usuario?.peso,
                        pesoObjetivo: prog?.objetivoPeso,
                        fechaObjetivo: prog?.fechaObjetivo,
                      ),
                      onTap: () => context.push(AppRoutes.profile),
                    );
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
                              color: actualTheme.colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomDivider(
                            color: actualTheme.colorScheme.tertiary,
                          ),
                          const SizedBox(height: 4),
                          if (prov.calorias != null &&
                              prov.tiempoPreparacion != null)
                            Text(
                              '${prov.calorias} kcal · ${prov.tiempoPreparacion} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: actualTheme.colorScheme.tertiary,
                              ),
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
                      onTap: () {},
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
