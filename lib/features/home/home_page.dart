import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/home/widgets/home_card.dart';
import 'package:track_fit_app/features/home/widgets/hydration_widget.dart';
import 'package:track_fit_app/features/trainer/service/daily_challenge_dialog.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';
import 'package:track_fit_app/notifiers/recipe_notifier.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Reto diario
    context.read<DailyChallengeNotifier>().ensureTodayChallengeExists();
    // Receta diaria
    context.read<RecipeNotifier>().initTodayRecipe();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cuando la app vuelve al foreground, volvemos a comprobar el reto
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
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
              children: [
                // Card 1: Rutina recomendada
                HomeCard(
                  icon: Icons.fitness_center,
                  title: 'Rutina top',
                  subtitle: 'Fuerza: Tren superior (4 ejercicios)',
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E5EA),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Container(
                            height: 6,
                            width: MediaQuery.of(context).size.width * 0.15,
                            // 2/4 completados ≈ 50% del ancho de una card
                            decoration: BoxDecoration(
                              color: actualTheme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '2 de 4 completados',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0x993C3C43),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigator.pushNamed(context, '/rutinaRecomendada');
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
                          color:
                              completado
                                  ? Colors
                                      .green
                                      .shade100 // fondo verde suave
                                  : const Color(0xFFFCD34D), // amarillo
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          completado ? 'Completado' : 'En progreso',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color:
                                completado
                                    ? Colors
                                        .green
                                        .shade800 // texto verde oscuro
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
                  icon: Icons.bar_chart, // 📈
                  title: 'Mi objetivo',
                  subtitle: '🔥 1.200 kcal\n 🏃‍♂️ 3 de 5 sesiones',
                  backgroundColor: const Color(0xFFF2F2F7),
                  // Como aquí tenemos dos métricas, incluimos un bottomWidget con una Row
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
                      // Aquí empaquetamos todos los campos en un Column
                      content = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prov.titulo!,
                            style: TextStyle(fontWeight: FontWeight.bold, color: actualTheme.colorScheme.tertiary),
                          ),
                          const SizedBox(height: 20),
                          CustomDivider(color: actualTheme.colorScheme.tertiary),
                          const SizedBox(height: 4),
                          if (prov.calorias != null &&
                              prov.tiempoPreparacion != null)
                            Text(
                              '${prov.calorias} kcal · ${prov.tiempoPreparacion} min',
                              style: TextStyle(fontSize: 12, color: actualTheme.colorScheme.tertiary),
                            ),
                        ],
                      );
                    } else {
                      content = const SizedBox();
                    }

                    return HomeCard(
                      icon: Icons.fastfood_rounded,
                      title: 'Nutrición', // Título fijo
                      subtitle: null, // Sin subtítulo
                      backgroundColor: const Color(0xFFF2F2F7),
                      bottomWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: content,
                      ),
                      onTap: () {
                        // Aquí podrías abrir detalle completo si quieres
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
