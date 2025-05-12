import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passController.text,
      );
      // Si la autenticación fue exitosa, ahora inserta el perfil en la tabla `usuarios`.
      final userId = response.user?.id;
      if (userId != null) {
        final newUser = {
          'auth_user_id': userId,
          'created_at': DateTime.now().toIso8601String(),
          // Puedes agregar valores predeterminados o `null` donde sea necesario
        };
        await supabase.from('usuarios').insert(newUser);
      }
      _showMessage('¡Registro exitoso! Revisa tu correo para confirmar.');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Error inesperado: $error');
    }
  }

  Future<void> _signIn() async {
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passController.text,
      );
      // Si no lanza excepción, vamos al home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Error inesperado: $error');
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _signIn, child: const Text('Ingresar')),
                ElevatedButton(onPressed: _signUp, child: const Text('Registrarse')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
