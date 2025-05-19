import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/themes/app_themes.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/di/di.dart';
import 'package:track_fit_app/features/profile/profile_page.dart';
import 'package:track_fit_app/features/routines/routine_page.dart';
import 'package:track_fit_app/features/trainer/trainer_page.dart';

import 'auth/complete_profile_page.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';
import 'features/home/home_page.dart';

/// Clave global para navegar desde el listener de auth
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  // 1) Inicializamos Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );

  // 2) Inyectamos dependencias
  setupDependencies();

  // 3) Cierra la sesión del usuario y te redirige a la pantalla de login.
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final event = data.event;
    if (event == AuthChangeEvent.signedOut) {
      // si alguien se cierra sesión en cualquier parte,
      // la app navega sola al login
      _navKey.currentState?.pushReplacementNamed(AppRoutes.login);
    }
  });

  // 4) Leemos la sesión actual
  final supabase = Supabase.instance.client;
  final session = supabase.auth.currentSession;

  // 5) Decidimos la pantalla inicial
  Widget initialScreen;
  if (session == null) {
    // No hay usuario logueado
    initialScreen = const LoginPage();
  } else {
    // Hay sesión: comprobamos si el perfil está completo
    final profile =
        await supabase
            .from('usuarios')
            .select()
            .eq('auth_user_id', session.user.id)
            .maybeSingle();
    const required = ['nombre_usuario', 'nombre', 'apellidos'];
    final needsProfile =
        profile == null || required.any((field) => profile[field] == null);
    initialScreen =
        needsProfile ? const CompleteProfilePage() : const HomePage();
  }

  // 6) Arrancamos la app con la pantalla adecuada
  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({required this.initialScreen, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App con Supabase',
      navigatorKey: _navKey,
      home: initialScreen,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.completeProfile: (context) => const CompleteProfilePage(),
        AppRoutes.home: (context) => const HomePage(),
        AppRoutes.routines: (context) => RoutinePage(),
        AppRoutes.trainer: (context) => TrainerPage(),
        AppRoutes.profile: (context) => ProfilePage(),
      },
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
