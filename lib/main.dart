import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/navigation/main_scaffold.dart';
import 'package:track_fit_app/core/themes/app_themes.dart';
import 'package:track_fit_app/core/themes/logo_type.dart';
import 'package:track_fit_app/di/di.dart';

import 'auth/complete_profile_page.dart';
import 'auth/login_page.dart';
import 'auth/register_page.dart';

/// Clave global para navegar desde el listener de auth
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  setupDependencies(); // 👈 ¡Aquí se inicializa todo!

  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;

    if (event == AuthChangeEvent.signedIn && session != null) {
      final user = session.user;

      final profile =
          await Supabase.instance.client
              .from('usuarios')
              .select()
              .eq('auth_user_id', user.id)
              .maybeSingle();

      bool needsProfile = false;
      if (profile == null) {
        needsProfile = true;
      } else {
        const required = ['nombre_usuario', 'nombre', 'apellidos'];
        for (var field in required) {
          if (profile[field] == null) {
            needsProfile = true;
            break;
          }
        }
      }

      if (needsProfile) {
        _navKey.currentState?.pushReplacementNamed(AppRoutes.completeProfile);
      } else {
        _navKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      }
    } else if (event == AuthChangeEvent.signedOut) {
      _navKey.currentState?.pushReplacementNamed(AppRoutes.login);
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App con Supabase',
      navigatorKey: _navKey,
      initialRoute: '/login',
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.register: (context) => const RegisterPage(),
        AppRoutes.completeProfile: (context) => const CompleteProfilePage(),
      },

      theme: AppThemes.themeForLogo(LogoType.blancoNegro).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Theme.of(context).colorScheme.onSecondary,
          selectionHandleColor: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
      // opcionalmente podrías tener otro tema para darkMode:
      // darkTheme: AppThemes.themeForLogo(LogoType.blancoNegro),
      // themeMode: ThemeMode.system,
    );
  }
}
