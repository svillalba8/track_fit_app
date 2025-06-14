import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/core/themes/theme_notifier.dart';

/// Página para que el usuario seleccione un tema de la app.
/// Muestra una lista de tarjetas con cada logo y, al tocar, cambia el tema y vuelve al perfil.
class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene el notifier que gestiona el tema actual
    final themeNotifier = context.watch<ThemeNotifier>();
    // Filtra solo los LogoType que representan temas válidos
    final themeOptions = LogoType.values.where((logo) => logo.isTheme).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar tema')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                themeOptions.map((logo) {
                  final isSelected = themeNotifier.currentLogo == logo;
                  return GestureDetector(
                    // Al tocar, actualiza el tema y navega de regreso al perfil
                    onTap: () {
                      themeNotifier.setLogo(logo);
                      context.go(AppRoutes.profile);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation:
                          isSelected ? 4 : 1, // Resalta el tema seleccionado
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Muestra el logo a la izquierda
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                logo.assetPath,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nombre del tema centrado
                            Expanded(
                              child: Center(
                                child: Text(
                                  logo.displayName,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            // Radio que indica el tema activo
                            Radio<LogoType>(
                              value: logo,
                              groupValue: themeNotifier.currentLogo,
                              onChanged: (selected) {
                                if (selected != null) {
                                  themeNotifier.setLogo(selected);
                                  context.go(AppRoutes.profile);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
