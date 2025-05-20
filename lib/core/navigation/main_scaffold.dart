import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/core/constants.dart';

/// Scaffold principal con BottomNavigation y contenido dinámico via ShellRoute
class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({required this.child, super.key});

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
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => _onTap(context, i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Entrenador',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
