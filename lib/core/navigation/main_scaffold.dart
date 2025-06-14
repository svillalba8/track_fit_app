import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/notifiers/auth_user_notifier.dart';

/// Scaffold principal con BottomNavigation y contenido dinámico via ShellRoute
class MainScaffold extends StatelessWidget {
  /// Índice de la pestaña activa (pasado por GoRouter)
  final int currentIndex;

  /// Callback para cambiar de pestaña (`nav.goBranch`)
  final void Function(int index, {bool initialLocation}) onTap;

  /// Contenido dinámico (el `NavigationShell`)
  final Widget child;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.child,
  });

  /// Calcula el índice de pestaña a partir de la ruta actual
  int _calculateIndex(BuildContext context) {
    final location = GoRouter.of(context).location;
    switch (location) {
      case AppRoutes.home:
        return 0;
      case AppRoutes.routines:
        return 1;
      case AppRoutes.trainer:
        return 2;
      case AppRoutes.profile:
        return 3;
      default:
        return 0;
    }
  }

  /// Navega a la ruta correspondiente cuando se pulsa un ítem
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.routines);
        break;
      case 2:
        context.go(AppRoutes.trainer);
        break;
      case 3:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el índice real según la ruta
    final index = _calculateIndex(context);
    final actualTheme = Theme.of(context);

    // Obtiene el usuario para decidir el icono de perfil
    final usuario = context.watch<AuthUserNotifier>().usuario;
    final genero = usuario?.genero ?? kGeneroHombreMayus;
    final iconPrefix =
        genero == kGeneroHombreMayus ? 'perfil_usuario_h' : 'perfil_usuario_m';

    return Theme(
      // Personaliza efectos de splash/highlight en toda la barra
      data: actualTheme.copyWith(
        splashFactory: NoSplash.splashFactory,
        splashColor: actualTheme.colorScheme.onSurface.withAlpha(
          (0.60 * 255).round(),
        ),
        highlightColor: Colors.transparent,
      ),
      child: Scaffold(
        body: child, // Muestra el contenido de la pestaña activa
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Divider encima de la BottomNavigationBar
            Divider(
              height: 1,
              thickness: 1,
              color: actualTheme.colorScheme.onSurface.withAlpha(
                (0.40 * 255).round(),
              ),
            ),
            BottomNavigationBar(
              currentIndex: index,
              onTap: (i) => _onTap(context, i),
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: actualTheme.colorScheme.primary,
              selectedItemColor: actualTheme.colorScheme.secondary,
              unselectedItemColor: actualTheme.colorScheme.onSurface.withAlpha(
                (0.60 * 255).round(),
              ),
              items: [
                // Home
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/casa.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  activeIcon: Image.asset(
                    'assets/icons/casa_en_uso.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  label: '',
                ),
                // Routines
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/pesa.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  activeIcon: Image.asset(
                    'assets/icons/pesa_en_uso.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  label: '',
                ),
                // Trainer
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/entrenador_per.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  activeIcon: Image.asset(
                    'assets/icons/entrenador_per_en_uso.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  label: '',
                ),
                // Profile (icono varía por género)
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/$iconPrefix.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  activeIcon: Image.asset(
                    'assets/icons/${iconPrefix}_en_uso.png',
                    width: 26,
                    height: 26,
                    color: actualTheme.colorScheme.secondary,
                  ),
                  label: '',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
