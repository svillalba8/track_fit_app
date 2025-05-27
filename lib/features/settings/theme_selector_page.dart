import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/core/themes/theme_notifier.dart';

class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();
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
                    onTap: () {
                      themeNotifier.setLogo(logo);
                      context.go('/profile');
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: isSelected ? 4 : 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // Logo a la izquierda
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

                            // Texto centrado
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

                            // Radio a la derecha
                            Radio<LogoType>(
                              value: logo,
                              groupValue: themeNotifier.currentLogo,
                              onChanged: (selected) {
                                if (selected != null) {
                                  themeNotifier.setLogo(selected);
                                  context.go('/profile');
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
