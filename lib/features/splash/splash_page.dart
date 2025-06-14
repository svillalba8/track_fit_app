import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants.dart';

/// Página inicial que muestra un loader y redirige según estado de autenticación/perfil
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndProfile(); // Inicia la comprobación al montar
  }

  /// 1) Obtiene sesión actual de Supabase
  /// 2) Si no hay sesión, navega a login
  /// 3) Si hay sesión, carga perfil de 'usuarios'
  /// 4) Si faltan campos clave, va a completeProfile; si no, a home
  Future<void> _checkAuthAndProfile() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (session == null) {
      context.go(AppRoutes.login);
      return;
    }

    final profile =
        await supabase
            .from('usuarios')
            .select()
            .eq('auth_user_id', session.user.id)
            .maybeSingle();

    const required = ['nombre_usuario', 'nombre', 'apellidos'];
    final needsProfile =
        profile == null || required.any((f) => profile[f] == null);

    if (!mounted) return;
    context.go(needsProfile ? AppRoutes.completeProfile : AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    // Muestra indicador mientras decide la ruta
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
