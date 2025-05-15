import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/register_page.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/email_field.dart';
import 'package:track_fit_app/auth/widgets/password_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/widgets/link_text.dart';
import '../widgets/custom_button.dart';
import '../core/constants.dart';
import '../features/home/home_page.dart';

/// Página de login optimizada con diseño elegante
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false;
  bool _obscureRepeat = true;

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
                        passController: _passController,
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
                                _passController.text,
                              );

                          // 2) Si hay un mensaje de error, lo mostramos y salimos
                          if (errorMessage != null) {
                            showErrorSnackBar(context, errorMessage);
                            return;
                          }

                          // 3) Si todo OK, lanzamos el signup
                          if (!_loading) {
                            _signIn();
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

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
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

  /// Traduce los mensajes de la API a textos amigables para el usuario.
  String _mapSignInError(String apiMsg) {
    switch (apiMsg) {
      case 'Invalid login credentials':
        // credenciales incorrectas
        return 'Usuario o contraseña incorrectos.';

      case 'Email not confirmed':
        // cuenta no verificada
        return 'Tu correo no está confirmado. Revisa tu bandeja.';

      case 'Password should be a string with minimum length of 6':
        // contraseña muy corta
        return 'La contraseña debe tener al menos 6 caracteres.';

      case 'Unexpected error':
        // error genérico del servidor
        return 'Ha ocurrido un error inesperado. Vuelve a intentarlo.';
        
      default:
        // cualquier otro caso
        return apiMsg;
    }
  }
}
