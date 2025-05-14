import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/widgets/link_text.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

/// Página de registro optimizada con diseño elegante
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfiormController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false;
  bool _obscureRepeat = true;

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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Registro exitoso! Revisa tu correo para confirmar.'),
        ),
      );
    } on AuthException catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error inesperado: $error')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                      Text('Crear Cuenta', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),

                      // Email
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Contraseña
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRepeat
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureRepeat = !_obscureRepeat;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureRepeat,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Confirmar contraseña
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _passConfiormController,
                          decoration: InputDecoration(
                            labelText: 'Repetir contraseña',
                            border: InputBorder.none,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRepeat
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureRepeat = !_obscureRepeat;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscureRepeat,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón de registro
                      CustomButton(
                        text: _loading ? 'Cargando...' : 'Crear cuenta',
                        actualTheme: Theme.of(context),
                        onPressed: () {
                          if (!_loading) _signUp();
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
}
