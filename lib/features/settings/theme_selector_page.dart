import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/core/themes/theme_notifier.dart';

class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar tema')),
      body: ListView(
        children:
            LogoType.values.map((logo) {
              return RadioListTile<LogoType>(
                title: Text(logo.name),
                value: logo,
                groupValue: themeNotifier.currentLogo,
                onChanged: (selected) {
                  if (selected != null) {
                    themeNotifier.setLogo(selected);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
      ),
    );
  }
}
