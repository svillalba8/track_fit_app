import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/complete_profile_page.dart';
import 'package:track_fit_app/auth/register_page.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/email_field.dart';
import 'package:track_fit_app/auth/widgets/password_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';
import 'package:track_fit_app/widgets/link_text.dart';

import '../core/constants.dart';
import '../widgets/custom_button.dart';

/// Página de login optimizada con diseño elegante
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false;
  bool _obscureRepeat = true;
  late final StreamSubscription<AuthState> _authSub;

  @override
  void initState() {
    super.initState();
    // Inicia escucha de cambios en auth para gestionar el flujo tras login
    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;
      // Si el usuario acaba de iniciar sesión, procesamos el siguiente paso
      if (event == AuthChangeEvent.signedIn && user != null) {
        _afterLogin(user);
      }
    });
  }

  @override
  void dispose() {
    // Cancela la suscripción al cambiar de pantalla y libera controllers
    _authSub.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(kLogoTrackFitBlancoMorado, height: 120),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style: actualTheme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      EmailField(
                        emailController: _emailController,
                        actualTheme: actualTheme,
                      ),

                      const SizedBox(height: 12),

                      // Contraseña
                      PasswordField(
                        passController: _passwordController,
                        message: 'Contraseña',
                        actualTheme: actualTheme,
                        onToggleObscure: () {
                          setState(() => _obscureRepeat = !_obscureRepeat);
                        },
                        obscureRepeat: _obscureRepeat,
                      ),

                      const SizedBox(height: 24),

                      // Botón de inicio sesión
                      CustomButton(
                        text: _loading ? 'Cargando...' : 'Iniciar sesión',
                        actualTheme: Theme.of(context),
                        onPressed: () {
                          // 1) Ejecutamos todos los validadores y usamos el primero que devuelva error
                          final errorMessage =
                              AuthValidators.emailValidator(
                                _emailController.text,
                              ) ??
                              AuthValidators.passwordValidator(
                                _passwordController.text,
                              );

                          // 2) Si hay un mensaje de error, lo mostramos y salimos
                          if (errorMessage != null) {
                            showErrorSnackBar(context, errorMessage);
                            return;
                          }

                          // 3) Si todo OK, lanzamos el signup
                          if (!_loading) {
                            _signInWithEmail();
                          }
                        },
                      ),

                      const SizedBox(height: 36),

                      LinkText(
                        text: '¿No tienes cuenta? Regístrate',
                        underline: false,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            ),
                      ),

                      const SizedBox(height: 9),

                      // Separador
                      Center(
                        child: Text(
                          'O',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // OAuth: Google
                      CustomIconButton(
                        icon: Image.asset('assets/logos/google_logo_icon.png'),
                        texto: 'Continuar con Google',
                        actualTheme: actualTheme,
                        onPressed: () {
                          if (!_loading) {
                            _signInWithGoogle();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmail() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
    } on AuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, _mapSignInError(e.message));
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      // Inicia OAuth con Google
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.trackfit://login-callback',
        authScreenLaunchMode: LaunchMode.inAppWebView,
      );
    } catch (e) {
      // Captura errores de OAuth
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Google Sign-In: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _afterLogin(User user) async {
    // Verifica si el perfil existe en la tabla 'usuarios'
    final profile =
        await supabase
            .from('usuarios')
            .select()
            .eq('auth_user_id', user.id)
            .maybeSingle();

    if (!mounted) return;
    if (profile == null) {
      // Si no hay perfil, navegamos hasta a la pantalla de completar perfil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CompleteProfilePage(userId: user.id)),
      );
    } else {
      // Si ya existe, llevamos al usuario al home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// Traduce los mensajes de la API a textos amigables para el usuario.
  String _mapSignInError(String apiMsg) {
    switch (apiMsg) {
      case 'Invalid login credentials':
        // credenciales incorrectas
        return 'Usuario o contraseña incorrectos.';

      case 'Email not confirmed':
        // cuenta no verificada
        return 'Tu correo no está confirmado. Revisa tu bandeja.';

      case 'User not found':
        // usuario no existente
        return 'No existe ninguna cuenta con ese correo.';

      case 'User already registered':
      case 'email_exists':
        // correo ya registrado
        return 'Este correo ya está en uso.';

      case 'Password should be a string with minimum length of 6':
        // contraseña muy corta
        return 'La contraseña debe tener al menos 6 caracteres.';

      case 'Unexpected error':
        // error genérico del servidor
        return 'Ha ocurrido un error inesperado. Vuelve a intentarlo.';

      default:
        // cualquier otro mensaje
        return apiMsg;
    }
  }
}
