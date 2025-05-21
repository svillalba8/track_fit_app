import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/notifiers/auth_user_notifier.dart';

/// Scaffold principal con BottomNavigation y contenido dinámico via ShellRoute
class MainScaffold extends StatelessWidget {
  /// Índice de la pestaña activa
  final int currentIndex;

  /// Callback para cambiar de pestaña (usa nav.goBranch)
  final void Function(int index, {bool initialLocation}) onTap;

  /// Contenido dinámico (el NavigationShell)
  final Widget child;

  const MainScaffold({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.child,
  });

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
    final currentIndex = _calculateIndex(context);
    final actualTheme = Theme.of(context);

    // 1) Obtén el usuario de tu ChangeNotifier
    final authNotifier = context.watch<AuthUserNotifier>();
    final usuario = authNotifier.usuario;

    // 2) Decide un prefijo por defecto si por alguna razón es null
    final genero = usuario?.genero ?? kGeneroHombreMayus;
    final iconPrefix =
        genero == kGeneroHombreMayus ? 'perfil_usuario_h' : 'perfil_usuario_m';

    return Theme(
      data: actualTheme.copyWith(
        // Usa el splash circular clásico, o NoSplash.splashFactory para eliminarlo
        splashFactory: NoSplash.splashFactory, // o NoSplash.splashFactory
        // Color del fogonazo: aquí un 20% de tu secondary
        splashColor: actualTheme.colorScheme.onSurface.withAlpha(
          (0.60 * 255).round(),
        ),
        // Quita el highlight si no lo quieres ver
        highlightColor: Colors.transparent,
      ),
      child: Scaffold(
        body: child,
        bottomNavigationBar: Column(
          mainAxisSize:
              MainAxisSize.min, // Solo ocupa lo necesario (divider + bar)
          children: [
            Divider(
              height: 1, // altura total del Divider
              thickness: 1, // grosor de la línea
              color: actualTheme.colorScheme.onSurface.withAlpha(
                (0.40 * 255).round(),
              ),
            ),
            BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => _onTap(context, i),
              type: BottomNavigationBarType.fixed,
              enableFeedback: false,
              showSelectedLabels: false, // quita el label activo
              showUnselectedLabels: false, // quita los labels inactivos
              backgroundColor: actualTheme.colorScheme.primary,
              selectedItemColor: actualTheme.colorScheme.secondary,
              unselectedItemColor: actualTheme.colorScheme.onSurface.withAlpha(
                (0.60 * 255).round(),
              ),
              items: [
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
