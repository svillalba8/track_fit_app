import 'package:flutter/material.dart';
import 'package:track_fit_app/core/constants.dart';

import '../services/navigation_service.dart';

class NavigationWidget {
  static BottomNavigationBar customBottonNavigationBar(BuildContext context, int defaultIndex) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          key: Key(AppRoutes.home),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          key: Key(AppRoutes.routines),
          label: "Rutinas",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_search),
          key: Key(AppRoutes.trainer),
          label: "Entrenador",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          key: Key(AppRoutes.profile),
          label: "Perfil",
        ),
      ],
      currentIndex: defaultIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            NavigationService.navigateTo(context, AppRoutes.home);
            break;
          case 1:
            NavigationService.navigateTo(context, AppRoutes.routines);
            break;
          case 2:
            NavigationService.navigateTo(context, AppRoutes.trainer);
            break;
          case 3:
            NavigationService.navigateTo(context, AppRoutes.profile);
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
    );
  }
}
