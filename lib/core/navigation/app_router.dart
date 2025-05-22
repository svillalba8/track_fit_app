import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/complete_profile_page.dart';
import 'package:track_fit_app/auth/login_page.dart';
import 'package:track_fit_app/auth/register_page.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/navigation/main_scaffold.dart';
import 'package:track_fit_app/core/utils/steram_listenable.dart';
import 'package:track_fit_app/features/home/home_page.dart';
import 'package:track_fit_app/features/profile/profile_page.dart';
import 'package:track_fit_app/features/routines/routine_page.dart';
import 'package:track_fit_app/features/settings/user_settings_page.dart';
import 'package:track_fit_app/features/splash/splash_page.dart';
import 'package:track_fit_app/features/trainer/trainer_page.dart';
import 'package:track_fit_app/models/usuario_model.dart';

/// Configuración de rutas usando GoRouter
final GoRouter appRouter = GoRouter(
  // Escucha los cambios de autenticación y fuerza a GoRouter a reevalúar el redirect cada vez que haya un evento
  refreshListenable: StreamListenable(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  initialLocation: AppRoutes.splash,

  // Lógica de guardia: redirige según el estado de la sesión y la ruta actual
  redirect: (ctx, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggingIn =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;
    if (session == null && !loggingIn) return AppRoutes.login;
    if (session != null && loggingIn) return AppRoutes.home;
    return null;
  },

  routes: <RouteBase>[
    // 1) Splash (pantalla de decisión)
    GoRoute(
      path: AppRoutes.splash, // aquí pones la ruta '/'
      builder: (ctx, state) => const SplashPage(),
    ),

    // 2) Autenticación
    GoRoute(path: AppRoutes.login, builder: (ctx, state) => const LoginPage()),
    GoRoute(
      path: AppRoutes.register,
      builder: (ctx, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      builder: (ctx, state) => const CompleteProfilePage(),
    ),

    /// 3) StatefulShellRoute con IndexedStack para conservar el estado
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext ctx,
        GoRouterState state,
        StatefulNavigationShell nav,
      ) {
        // Ahora MainScaffold recibe el índice y el callback para cambiar de rama
        return MainScaffold(
          currentIndex: nav.currentIndex,
          onTap: nav.goBranch,
          child: nav,
        );
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.routines,
              builder: (_, __) => const RoutinePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.trainer,
              builder: (_, __) => const TrainerPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: AppRoutes.editUser,
                  builder: (ctx, state) {
                    final usuario = state.extra as UsuarioModel;
                    return UserSettingsPage(usuario: usuario);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
