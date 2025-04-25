import 'package:flutter/material.dart';
import 'package:track_fit_app/screens/login_screen.dart';
import 'package:track_fit_app/utils/constants.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                kLogoTrackFitBlancoMorado,
                width: 150,
              ),
              SizedBox(height: 32),
              Text(
                'Regístrate',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
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
              SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar contraseña'),
              ),
              SizedBox(height: 32),
              // Botón para crear cuenta
              CustomButton(
                text: 'Crear cuenta',
                onPressed: () {
                  // Aquí iría la lógica de registro
                  Navigator.pop(context); // Vuelve a Login al crear cuenta
                },
              ),
              SizedBox(height: 16),
              // Enlace para volver al login
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text("Ya tienes cuenta, ve a iniciar sesión."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
