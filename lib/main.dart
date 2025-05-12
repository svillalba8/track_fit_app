import 'package:flutter/material.dart';
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => GetIt.instance.get<AuthBloc>())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "TrackFit",
        routes: {
          AppRoutes.initial: (context) => LoginScreen(),
          AppRoutes.register: (context) => SignUpScreen(),
          AppRoutes.login: (context) => LoginScreen(),
        },
        initialRoute: AppRoutes.initial,
      ),
    );
  }
}
