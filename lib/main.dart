import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/navigation/app_router.dart';
import 'package:track_fit_app/core/themes/app_themes.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/notifiers/auth_user_notifier.dart';
import 'package:track_fit_app/notifiers/chat_notifier.dart';

/// Separa toda la inicialización en este método:
Future<void> initializeApp() async {
  // 1. Inicializa el binding de Flutter para que los plugins y servicios estén disponibles
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carga el .env (opcionalmente con nombre de archivo)
  try {
    await dotenv.load();
  } catch (e) {
    // Aquí podrías reportar/loguear el error si falla la carga
    debugPrint('No se pudo cargar .env: $e');
  }

  // 3. Inicializa Supabase con las variables del .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );

  // 4. Registra tus dependencias (GetIt, Riverpod, etc.)
  setupDependencies();
}

Future<void> main() async {
  // Llama a la inicialización
  await initializeApp();

  // 5. Arranca la app inyectando tu provider de autenticación
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthUserNotifier()),
        ChangeNotifierProvider(create: (_) => ChatNotifier()),
      ],
      child: const MyApp(),
    ),
  );
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
