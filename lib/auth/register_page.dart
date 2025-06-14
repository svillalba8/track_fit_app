import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/service/auth_service.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/email_field.dart';
import 'package:track_fit_app/auth/widgets/password_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/widgets/link_text.dart';

import '../core/constants.dart';
import '../widgets/custom_button.dart';

/// Página de registro de usuario
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores para campos de email y contraseña
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfirmController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false; // Indica carga de petición
  bool _obscureRepeat = true; // Oculta/mostrar contraseña

  // Servicio de autenticación
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo con color adaptado al tema
              Image.asset(
                kLogoTrackFitBlancoSinFondo,
                height: 120,
                color:
                    theme.colorScheme.secondary == const Color(0xFFD9B79A)
                        ? theme.colorScheme.tertiary
                        : theme.colorScheme.secondary,
              ),
              const SizedBox(height: 32),

              // Card que agrupa el formulario
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Título
                      Text('Crear Cuenta', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Campo de email
                      EmailField(
                        emailController: _emailController,
                        actualTheme: theme,
                      ),
                      const SizedBox(height: 24),

                      // Campo de contraseña
                      PasswordField(
                        passController: _passController,
                        message: 'Contraseña',
                        actualTheme: theme,
                        obscureRepeat: _obscureRepeat,
                        onToggleObscure: () {
                          setState(() => _obscureRepeat = !_obscureRepeat);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Campo de confirmación de contraseña
                      PasswordField(
                        passController: _passConfirmController,
                        message: 'Repetir contraseña',
                        actualTheme: theme,
                        obscureRepeat: _obscureRepeat,
                        onToggleObscure: () {
                          setState(() => _obscureRepeat = !_obscureRepeat);
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botón de crear cuenta
                      CustomButton(
                        text: _loading ? 'Cargando...' : 'Crear cuenta',
                        actualTheme: theme,
                        onPressed: () {
                          // Valida email, contraseña y confirmación
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
                          if (errorMessage != null) {
                            showErrorSnackBar(context, errorMessage);
                            return;
                          }
                          if (!_loading) _signUp(); // Lanza lógica de registro
                        },
                      ),
                      const SizedBox(height: 34),

                      // Enlace para ir a login
                      LinkText(
                        text: '¿Ya tienes cuenta? Inicia sesión',
                        underline: false,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: () => context.go(AppRoutes.login),
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

  ///  Registra al usuario en Supabase:
  ///  1) Validación local
  ///  2) Pre-check RPC para email existente
  ///  3) SignUp y manejo de errores
  Future<void> _signUp() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    // Validación local antes de llamada remota
    final localError =
        AuthValidators.emailValidator(email) ??
        AuthValidators.passwordValidator(password) ??
        AuthValidators.confirmPasswordValidator(
          _passConfirmController.text,
          password,
        );
    if (localError != null) {
      if (!mounted) return;
      showErrorSnackBar(context, localError);
      return setState(() => _loading = false);
    }

    // Comprueba existencia de email vía RPC
    final exists = await _authService.emailExists(email);
    if (!mounted) return;
    if (exists) {
      showErrorSnackBar(context, 'Este correo ya está en uso.');
      return setState(() => _loading = false);
    }

    // Llama a signUp de Supabase y maneja errores
    try {
      await _authService.signUp(email: email, password: password);
      if (!mounted) return;
      showSuccessSnackBar(
        context,
        'Te hemos enviado un correo para confirmar tu cuenta. Revisa tu bandeja.',
      );
      context.go(AppRoutes.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      final msg = e.message.toLowerCase();
      if (msg.contains('user already registered') ||
          msg.contains('email_exists') ||
          msg.contains('duplicate key')) {
        showErrorSnackBar(context, 'Este correo ya está en uso.');
      } else {
        showErrorSnackBar(context, _authService.mapError(e.message));
      }
    } catch (_) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error inesperado. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
