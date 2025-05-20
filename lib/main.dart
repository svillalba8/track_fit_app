import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/navigation/app_router.dart';
import 'package:track_fit_app/core/themes/app_themes.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/di/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );

  // Inyectar dependencias
  setupDependencies();

  // Arranca la aplicación con GoRouter
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mi App con Supabase',
      routerConfig: appRouter,
      theme: AppThemes.themeForLogo(LogoType.blancoMorado).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Theme.of(context).colorScheme.onSecondary,
          selectionHandleColor: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      // Para ocultar el teclado al tocar fuera
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: child,
        );
      },
    );
  }
}
