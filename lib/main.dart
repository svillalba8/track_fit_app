import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'themes/logo_type.dart';
import 'themes/theme_notifier.dart';

Future<void> main() async {
  // 1) Carga las variables del .env
  await dotenv.load(fileName: '.env');

  // 2) Inicializa Supabase con tus credenciales
  final supabaseUrl = dotenv.get('SUPABASE_URL');
  final supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY');
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authFlowType: AuthFlowType.pkce,
  );

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
