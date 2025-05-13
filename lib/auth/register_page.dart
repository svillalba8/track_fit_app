import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/custom_button.dart';
import '../widgets/redirect_text_button.dart';
import '../utils/constants.dart';
import 'home_page.dart';

/// Página de registro optimizada con diseño elegante
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final supabase = Supabase.instance.client;
  bool _loading = false;

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
        const SnackBar(content: Text('¡Registro exitoso! Revisa tu correo para confirmar.')),
      );
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $error')),
      );
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
              Image.asset(
                kLogoTrackFitBlancoMorado,
                height: 120,
              ),
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
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // Contraseña
                      TextField(
                        controller: _passController,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      // Botón de registro
                      CustomButton(
                        text: _loading ? 'Cargando...' : 'Crear cuenta',
                        onPressed: () {
                          if (!_loading) _signUp();
                        },
                        colorTheme: theme.colorScheme.primary,
                      ),

                      const SizedBox(height: 12),

                      // Enlace a login
                      RedirectTextButton(
                        text: '¿Ya tienes cuenta? Inicia sesión',
                        function: () {
                          Navigator.of(context).pop();
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
}
