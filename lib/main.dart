import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'themes/logo_type.dart';
import 'themes/theme_notifier.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(LogoType.rosaNegro),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha el ThemeNotifier y obtiene el ThemeData actual
    final theme = context.watch<ThemeNotifier>().themeData;

    return MaterialApp(
      title: 'Fitness App',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
