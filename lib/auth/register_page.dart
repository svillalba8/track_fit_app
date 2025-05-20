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

  /// Lógica de registro con Supabase, pre‐check RPC y mapeo de errores
  final _authService = AuthService();

  Future<void> _signUp() async {
    setState(() => _loading = true);

    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    // Validación local
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
      setState(() => _loading = false);
      return;
    }

    // Pre-check
    final exists = await _authService.emailExists(email);
    if (!mounted) return;
    if (exists) {
      showErrorSnackBar(context, 'Este correo ya está en uso.');
      setState(() => _loading = false);
      return;
    }

    // Sign up
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
      setState(() => _loading = false);
    }
  }
}
