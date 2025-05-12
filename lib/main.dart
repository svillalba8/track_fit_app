import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:track_fit_app/routes/app_routes.dart';
import 'package:track_fit_app/screens/sing_up_screen.dart';
import 'blocs/auth_bloc.dart';
import 'di.dart';
import 'screens/login_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar dependencias
  await setupDependencies(); // <-- Esto es lo importante

  runApp(MyApp());
=======
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
>>>>>>> origin/pantalla_login_singin
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance.get<AuthBloc>())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "TrackFit",
        routes: {
          AppRoutes.initial: (context) => LoginScreen(),
          AppRoutes.register: (context) => SignUpScreen(),
          AppRoutes.login : (context) => LoginScreen(),
        },
        initialRoute: AppRoutes.initial,
      ),
=======
    // Escucha el ThemeNotifier y obtiene el ThemeData actual
    final theme = context.watch<ThemeNotifier>().themeData;

    return MaterialApp(
      title: 'Fitness App',
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
>>>>>>> origin/pantalla_login_singin
    );
  }
}
