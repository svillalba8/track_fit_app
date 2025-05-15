import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/email_field.dart';
import 'package:track_fit_app/auth/widgets/password_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/widgets/link_text.dart';
import '../widgets/custom_button.dart';
import '../core/constants.dart';

/// Página de registro optimizada con diseño elegante
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
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
              // Logo de la app
              Image.asset(kLogoTrackFitBlancoMorado, height: 120),
              const SizedBox(height: 32),

              // Card del formulario
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
                        'Crear Cuenta',
                        style: actualTheme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      EmailField(
                        emailController: _emailController,
                        actualTheme: actualTheme,
                      ),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 12),

                      // Confirmar contraseña
                      PasswordField(
                        passController: _passConfirmController,
                        message: 'Repetir contraseña',
                        actualTheme: actualTheme,
                        onToggleObscure: () {
                          setState(() => _obscureRepeat = !_obscureRepeat);
                        },
                        obscureRepeat: _obscureRepeat,
                      ),

                      const SizedBox(height: 24),

                      // Botón de registro
                      CustomButton(
                        text: _loading ? 'Cargando...' : 'Crear cuenta',
                        actualTheme: Theme.of(context),
                        onPressed: () {
                          // 1) Ejecutamos todos los validadores y usamos el primero que devuelva error
                          final errorMessage =
                              AuthValidators.emailValidator(
                                _emailController.text,
                              ) ??
                              AuthValidators.passwordValidator(
                                _passController.text,
                              ) ??
                              AuthValidators.confirmPasswordValidator(
                                _passConfirmController.text,
                                _passController.text,
                              );

                          // 2) Si hay un mensaje de error, lo mostramos y salimos
                          if (errorMessage != null) {
                            showErrorSnackBar(context, errorMessage);
                            return;
                          }

                          // 3) Si todo OK, lanzamos el signup
                          if (!_loading) {
                            _signUp();
                          }
                        },
                      ),

                      const SizedBox(height: 34),

                      // Enlace a login
                      LinkText(
                        text: '¿Ya tienes cuenta? Inicia sesión',
                        underline: false,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: () => Navigator.of(context).pop(),
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

  /// Lógica de registro con Supabase y mapeo de errores
  Future<void> _signUp() async {
    setState(() => _loading = true);
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passController.text,
      );

      final userId = response.user?.id;
      if (userId != null) {
        await supabase.from('usuarios').insert({
          'auth_user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      showSuccessSnackBar(
        context,
        '¡Registro exitoso! Revisa tu correo para confirmar.',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, _mapSignUpError(e.message));
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Convierte mensajes crudos de Supabase en mensajes de usuario
  String _mapSignUpError(String apiMsg) {
    switch (apiMsg) {
      // — Email inválido
      case 'Invalid email address':
        return 'El formato del correo no es válido.';

      // — Correo ya usado
      case 'User already registered':
      case 'email_exists':
        return 'Este correo ya está en uso.';

      // — Registro deshabilitado en el servidor
      case 'Signups are disabled for email and password':
      case 'Sign ups (new account creation) are disabled on the server.':
        return 'El registro por correo está deshabilitado.';

      // — Contraseña débil o corta
      case 'Password should be a string with minimum length of 6':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'weak_password':
        return 'La contraseña es demasiado débil.';

      // — Parámetros mal formados
      case 'validation_failed':
        return 'Los datos introducidos no son válidos.';

      // — Límite de peticiones superado
      case 'conflict':
        return 'Parece que ya existe una operación en curso. Intenta de nuevo.';
      case 'over_request_rate_limit':
        return 'Demasiadas solicitudes. Espera un momento antes de volver a intentarlo.';
      case 'over_email_send_rate_limit':
        return 'Has enviado demasiados correos de confirmación. Vuelve a intentarlo más tarde.';

      // — CAPTCHA
      case 'captcha_failed':
        return 'No se pudo verificar el CAPTCHA.';

      // — Errores généricos del servidor
      case 'Internal server error':
        return 'Error interno. Inténtalo de nuevo más tarde.';

      // — Por defecto, devolvemos el mensaje crudo
      default:
        return apiMsg;
    }
  }
}
