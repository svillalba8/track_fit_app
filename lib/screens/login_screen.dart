import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_fit_app/blocs/auth_bloc.dart';
import 'package:track_fit_app/screens/home_screen.dart';
import 'package:track_fit_app/screens/sing_up_screen.dart';
import 'package:track_fit_app/utils/constants.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
          if (state is AuthSuccessLogin) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLoginForm(context);
        },
=======
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo en la parte superior
            Image.asset(
              kLogoTrackFitRosaNegro,
              width: 150,  // Tamaño ajustable del logo
            ),
            SizedBox(height: 32),
            // Título
            Text(
              'Iniciar Sesión', 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            // Campos de texto
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Contraseña'),
            ),
            SizedBox(height: 32),
            // Botón de "Entrar"
            CustomButton(
              text: 'Entrar',
              colorTheme: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            SizedBox(height: 16),
            // Enlace para registrarse
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                );
              },
              child: Text("¿No tienes cuenta? Regístrate"),
            ),
          ],
        ),
>>>>>>> origin/pantalla_login_singin
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            kLogoTrackFitBlancoMorado,
            width: 150,
          ),
          const SizedBox(height: 32),
          const Text(
            'Iniciar Sesión',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Correo electrónico'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña'),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Entrar',
            onPressed: () {
              context.read<AuthBloc>().add(OnLoginEvent(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
              ));
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            child: const Text("¿No tienes cuenta? Regístrate"),
          ),
        ],
      ),
    );
  }
}