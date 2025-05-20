// lib/features/splash/splash_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndProfile();
  }

  Future<void> _checkAuthAndProfile() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    // Si no está logueado, a login
    if (session == null) {
      context.go(AppRoutes.login);
      return;
    }

    // Está logueado: comprueba perfil
    final profile =
        await supabase
            .from('usuarios')
            .select()
            .eq('auth_user_id', session.user.id)
            .maybeSingle();

    const required = ['nombre_usuario', 'nombre', 'apellidos'];
    final needsProfile =
        profile == null || required.any((f) => profile[f] == null);

    context.go(needsProfile ? AppRoutes.completeProfile : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
