import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/complete_profile_page.dart';
import 'package:track_fit_app/auth/login_page.dart';
import 'package:track_fit_app/auth/register_page.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/navigation/main_scaffold.dart';
import 'package:track_fit_app/core/utils/stream_listenable.dart';
import 'package:track_fit_app/features/home/home_page.dart';
import 'package:track_fit_app/features/profile/edit_goal_page.dart';
import 'package:track_fit_app/features/profile/edit_user_page.dart';
import 'package:track_fit_app/features/profile/profile_page.dart';
import 'package:track_fit_app/features/routines/routine_page.dart';
import 'package:track_fit_app/features/settings/theme_selector_page.dart';
import 'package:track_fit_app/features/settings/user_settings_page.dart';
import 'package:track_fit_app/features/splash/splash_page.dart';
import 'package:track_fit_app/features/trainer/trainer_page.dart';
import 'package:track_fit_app/models/progreso_model.dart';
import 'package:track_fit_app/models/usuario_model.dart';

/// Configuración principal de rutas usando GoRouter
final GoRouter appRouter = GoRouter(
  // Vuelve a evaluar el redirect cuando cambia el estado de autenticación
  refreshListenable: StreamListenable(
    Supabase.instance.client.auth.onAuthStateChange,
  ),

  // Ruta inicial al iniciar la app
  initialLocation: AppRoutes.splash,

  // Lógica de guardias: redirige según sesión activa y ruta de login/register
  redirect: (ctx, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final loggingIn =
        state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;
    if (session == null && !loggingIn) {
      return AppRoutes.login; // Si no está auth, va a login
    }
    if (session != null && loggingIn) {
      return AppRoutes.home; // Si ya auth, evita login/register
    }
    return null; // No redirige
  },

  routes: <RouteBase>[
    // 1) SplashPage para pantalla de carga/inicial
    GoRoute(
      path: AppRoutes.splash,
      builder: (ctx, state) => const SplashPage(),
    ),

    // 2) Rutas de autenticación: login, registro, completar perfil
    GoRoute(path: AppRoutes.login, builder: (ctx, state) => const LoginPage()),
    GoRoute(
      path: AppRoutes.register,
      builder: (ctx, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      builder: (ctx, state) => const CompleteProfilePage(),
    ),

    /// 3) Shell con IndexedStack para mantener estado de pestañas
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext ctx,
        GoRouterState state,
        StatefulNavigationShell nav,
      ) {
        return MainScaffold(
          currentIndex: nav.currentIndex, // Índice activo de pestaña
          onTap: nav.goBranch, // Callback al cambiar pestaña
          child: nav, // Muestra la navegación interna
        );
      },
      branches: [
        // Rama 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
          ],
        ),
        // Rama 1: Routines
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.routines,
              builder: (_, __) => const RoutinePage(),
            ),
          ],
        ),
        // Rama 2: Trainer
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.trainer,
              builder: (_, __) => const TrainerPage(),
            ),
          ],
        ),
        // Rama 3: Profile y subrutas
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfilePage(),
              routes: [
                // 3.1) Settings dentro de Profile
                GoRoute(
                  path: 'settings', // /profile/settings
                  builder: (context, state) {
                    final usuario = state.extra! as UsuarioModel;
                    return UserSettingsPage(usuario: usuario);
                  },
                  routes: [
                    // Editar usuario
                    GoRoute(
                      path: 'edit-user', // /profile/settings/edit-user
                      builder: (context, state) {
                        final usuario = state.extra! as UsuarioModel;
                        return EditUserPage(usuario: usuario);
                      },
                    ),
                    // Selector de tema
                    GoRoute(
                      path: 'theme', // /profile/settings/theme
                      builder: (_, __) => const ThemeSelectorPage(),
                    ),
                  ],
                ),
                // 3.2) Editar objetivo de progreso
                GoRoute(
                  path: 'edit-goal', // /profile/edit-goal
                  builder: (context, state) {
                    final progreso = state.extra as ProgresoModel?;
                    return EditGoalPage(progreso: progreso);
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
