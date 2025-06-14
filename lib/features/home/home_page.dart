import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/data/di.dart';
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

import '../routines/models/exercise_model.dart';
import '../routines/models/routine_model.dart';
import '../routines/services/exercise_service.dart';
import '../routines/services/routine_service.dart';

// Pantalla principal de la aplicación: muestra resumen de rutinas, retos, ejercicios, objetivo, hidratación y nutrición
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Servicio para manejar el progreso del usuario
  late final ProgresoService _progresoService;
  // Future para obtener el progreso existente (si existe)
  Future<ProgresoModel?>? _futProgreso;

  // Rutina aleatoria seleccionada para mostrar
  Routine? rutinaAleatoria;
  // Lista de ejercicios del usuario
  List<Exercise> ejercicios = [];
  // Indicador de carga de ejercicios
  bool isLoadingEjercicios = true;
  // Índice actual de la página en PageView de ejercicios
  int currentPage = 0;

  // Servicio para manejar ejercicios y controlador de páginas
  final ExerciseService exerciseService = ExerciseService();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Observador del ciclo de vida para actualizar retos al reanudar la app
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController();
    // Inicializa el servicio de progreso con el cliente Supabase
    _progresoService = ProgresoService(Supabase.instance.client);

    // Carga inicial: rutina aleatoria y lista de ejercicios
    _cargarRutinaAleatoria();
    _cargarEjercicios();

    // Asegura que el reto diario de hoy exista o se cree
    context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
  }

  // Obtiene todas las rutinas y selecciona una al azar para mostrar
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

  // Carga lista de ejercicios desde el servicio y actualiza estado
  Future<void> _cargarEjercicios() async {
    setState(() => isLoadingEjercicios = true);
    final resultado = await exerciseService.getExercises();
    setState(() {
      ejercicios = resultado;
      isLoadingEjercicios = false;
      currentPage = 0;
    });
  }

  // Navega a la página anterior en el PageView de ejercicios
  void _goToPrevious() {
    if (currentPage > 0) {
      setState(() => currentPage -= 1);
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navega a la página siguiente en el PageView de ejercicios
  void _goToNext() {
    if (currentPage < ejercicios.length - 1) {
      setState(() => currentPage += 1);
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    // Limpia controlador y observador al destruir el estado
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve del fondo, verificar de nuevo el reto diario
    if (state == AppLifecycleState.resumed) {
      context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Inicializa una sola vez el Future del progreso según el usuario actual
    if (_futProgreso == null) {
      final usuario = Provider.of<UsuarioModel?>(context);
      final idProg = usuario?.idProgreso;
      _futProgreso =
          (idProg != null)
              ? _progresoService.fetchProgresoById(idProg)
              : Future.value(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    // Utiliza FutureBuilder para cargar datos del usuario autenticado
    return FutureBuilder<UsuarioModel?>(
      future: _fetchUsuario(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Indicador de carga mientras se obtiene el usuario
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          // Mensaje de error si falla la carga de perfil
          return const Scaffold(
            body: Center(child: Text('No se pudo cargar tu perfil')),
          );
        }

        final usuario = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            // Saludo personalizado con nombre de usuario
            title: Text('Bienvenido, ${usuario.nombreUsuario}'),
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
            // Configura un GridView con 2 columnas para mostrar tarjetas de contenido
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.87,
              children: [
                // TARJETA 1: Rutina aleatoria
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
                                      (buttonContext) => TextButton(
                                        onPressed: () async {
                                          // Abre diálogo con todas las rutinas y opción de entrenar
                                          final todasLasRutinas =
                                              await RoutineService()
                                                  .getRoutines();
                                          if (!buttonContext.mounted) return;
                                          showDialog(
                                            context: buttonContext,
                                            builder: (dialogContext) {
                                              return RutinasDialog(
                                                todasLasRutinas:
                                                    todasLasRutinas,
                                                onEntrenar: () {
                                                  if (rutinaAleatoria != null) {
                                                    dialogContext.push(
                                                      AppRoutes.routines,
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
                  onTap: () {},
                ),

                // TARJETA 2: Reto diario
                HomeCard(
                  icon: Icons.emoji_events,
                  title: 'Reto diario',
                  subtitle: 'Completa el reto diario de hoy.',
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 54),
                      // Muestra estado del reto: completado o en progreso
                      Consumer<DailyChallengeNotifier>(
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
                    ],
                  ),
                  onTap: () => DailyChallengeDialog.show(context),
                ),

                // TARJETA 3: Mis ejercicios
                HomeCard(
                  icon: Icons.directions_run,
                  title: 'Mis ejercicios',
                  subtitle:
                      ejercicios.isEmpty
                          ? 'No tienes ejercicios creados.'
                          : 'Revisa y gestiona tus ejercicios.',
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget:
                      isLoadingEjercicios
                          ? const Center(child: CircularProgressIndicator())
                          : ejercicios.isEmpty
                          ? null
                          : Column(
                            children: [
                              SizedBox(
                                height: 100,
                                // Carousel de ejercicios con PageView
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: ejercicios.length,
                                  onPageChanged:
                                      (index) =>
                                          setState(() => currentPage = index),
                                  itemBuilder: (context, index) {
                                    final ejercicio = ejercicios[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ejercicio.nombre,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1C1C1E),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            ejercicio.descripcion ??
                                                'Sin descripción',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0x993C3C43),
                                            ),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tipo: ${ejercicio.tipo.name}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  actualTheme
                                                      .colorScheme
                                                      .primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Controles para navegar entre ejercicios
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios),
                                    color: const Color(0xFF1C1C1E),
                                    onPressed:
                                        currentPage == 0 ? null : _goToPrevious,
                                  ),
                                  Text(
                                    '${currentPage + 1} / ${ejercicios.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF1C1C1E),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    color: const Color(0xFF1C1C1E),
                                    onPressed:
                                        currentPage == ejercicios.length - 1
                                            ? null
                                            : _goToNext,
                                  ),
                                ],
                              ),
                            ],
                          ),
                  onTap: () {},
                ),

                // TARJETA 4: Mi Objetivo de peso
                FutureBuilder<ProgresoModel?>(
                  future:
                      usuario.idProgreso != null
                          ? _progresoService.fetchProgresoById(
                            usuario.idProgreso!,
                          )
                          : Future.value(null),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      // Muestra spinner mientras carga el objetivo
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
                        pesoUsuario: usuario.peso,
                        pesoObjetivo: prog?.objetivoPeso,
                        fechaObjetivo: prog?.fechaObjetivo,
                      ),
                      onTap: () => context.push(AppRoutes.profile),
                    );
                  },
                ),

                // TARJETA 5: Hidratación diaria
                HomeCard(
                  icon: Icons.water_drop_outlined,
                  title: 'Agua diaria',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: HydrationWidget(),
                  onTap: () {},
                ),

                // TARJETA 6: Receta nutricional del día
                Consumer<DailyRecipeNotifier>(
                  builder: (_, prov, __) {
                    Widget content;
                    if (prov.isLoading) {
                      // Indica cuando está cargando la receta
                      content = const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Cargando receta…'),
                      );
                    } else if (prov.error != null) {
                      // Muestra error si falla la carga
                      content = Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Error: ${prov.error}'),
                      );
                      debugPrint('Error: ${prov.error}');
                    } else if (prov.titulo != null) {
                      // Muestra detalles de la receta (título, calorías, tiempo)
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

// Función auxiliar para obtener el usuario autenticado desde Supabase
Future<UsuarioModel?> _fetchUsuario() async {
  final supabase = getIt<SupabaseClient>();
  final authUser = supabase.auth.currentUser;
  if (authUser == null) return null;

  final usuarioService = getIt<UsuarioService>();
  return await usuarioService.fetchUsuarioByAuthId(authUser.id);
}
