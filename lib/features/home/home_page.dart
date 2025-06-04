import 'package:flutter/material.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/home/widgets/home_card.dart';
import 'package:track_fit_app/features/home/widgets/hydration_widget.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<UsuarioModel?> _fetchUsuario() async {
    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return null;

    final usuarioService = getIt<UsuarioService>();
    return await usuarioService.fetchUsuarioByAuthId(authUser.id);
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
                // Card 1: Reto del día
                HomeCard(
                  icon: Icons.emoji_events, // 🏆
                  title: 'Reto diario',
                  subtitle: 'Completa 10 min de yoga para hoy.',
                  backgroundColor: const Color(0xFFF9F9FC),
                  bottomWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCD34D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'En progreso',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1C1C1E),
                      ),
                    ),
                  ),
                  onTap: () {
                    // Navigator.pushNamed(context, '/retoDiario');
                  },
                ),

                // Card 2: Rutina recomendada
                HomeCard(
                  icon: Icons.fitness_center,
                  title: 'Rutina recomendada',
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

                // Card 3: Mi progreso
                HomeCard(
                  icon: Icons.bar_chart, // 📈
                  title: 'Mi objetivo',
                  subtitle: '🔥 1.200 kcal\n🏃‍♂️ 3 de 5 sesiones',
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

                // Card 4: Accesos rápidos
                HomeCard(
                  icon: Icons.local_fire_department_outlined, // 🔥
                  title: 'Racha',
                  subtitle: 'Un contador con tus días entrenados',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: null,
                  onTap: () {
                    // Navigator.pushNamed(context, '/racha');
                  },
                ),

                // Card 5: Hidratación diaria
                HomeCard(
                  icon: Icons.water_drop_outlined, // 💧
                  title: 'Hidratación diaria',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: HydrationWidget(),
                  onTap: () {},
                ),

                // Card 6: Recomendación alimentaria
                HomeCard(
                  icon: Icons.fastfood_rounded, // 🍔
                  title: 'Recomendación alimentaria',
                  subtitle: 'Consejos de nutrición adaptados a ti',
                  backgroundColor: const Color(0xFFF2F2F7),
                  bottomWidget: null,
                  onTap: () {
                    // Navigator.pushNamed(context, '/alimentacion');
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

class _QuickAccessIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessIcon({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.4 * 255).round()),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 28, color: const Color(0xFF007AFF)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1C1C1E)),
          ),
        ],
      ),
    );
  }
}
