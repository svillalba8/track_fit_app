import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/models/usuario_model.dart';

/// Notificador del usuario autenticado:
/// - Carga inicial del perfil
/// - Escucha cambios de sesión
/// - Permite recarga manual y cierre de sesión
class AuthUserNotifier extends ChangeNotifier {
  final SupabaseClient supabase = getIt<SupabaseClient>(); // Cliente Supabase
  final UsuarioService userApi = getIt<UsuarioService>(); // Servicio de usuario

  UsuarioModel? _usuario;
  bool _loading = true;
  late final StreamSubscription<AuthState> _authSubscription;

  AuthUserNotifier() {
    // 1) Carga inicial si ya hay sesión activa
    _init();

    // 2) Escucha eventos de auth (signedIn, signedOut...)
    _authSubscription = supabase.auth.onAuthStateChange.listen(
      _handleAuthChange,
    );
  }

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _loading;

  /// Carga inicial: si hay sesión, carga el usuario; si no, marca como cargado
  Future<void> _init() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    if (user != null) {
      await _loadUser(user.id);
    } else {
      _loading = false;
      notifyListeners();
    }
  }

  /// Maneja cambios de estado de autenticación
  void _handleAuthChange(AuthState state) {
    final event = state.event;
    final session = state.session;

    switch (event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
        if (session != null) {
          _loadUser(session.user.id);
        }
        break;
      case AuthChangeEvent.signedOut:
        _usuario = null;
        notifyListeners();
        break;
      default:
        break;
    }
  }

  /// Carga perfil desde API y actualiza estado de carga
  Future<void> _loadUser(String userId) async {
    _loading = true;
    notifyListeners();

    try {
      _usuario = await userApi.fetchUsuarioByAuthId(userId);
    } catch (e) {
      _usuario = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fuerza una recarga manual del perfil actual
  Future<void> refreshUser() async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    if (user != null) {
      await _loadUser(user.id);
    }
  }

  /// Cierra la sesión; el listener manejará el signedOut
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  void dispose() {
    _authSubscription.cancel(); // Detiene la escucha de auth
    super.dispose();
  }
}
