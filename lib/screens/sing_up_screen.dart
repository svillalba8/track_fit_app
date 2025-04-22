import 'package:flutter/material.dart';
import 'package:track_fit_app/utils/constants.dart';
import '../widgets/custom_button.dart';

class SignUpScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Cuenta')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Logo en la parte superior
              Image.asset(
                kLogoTrackFitBlancoMorado, 
                width: 150,  // Tamaño ajustable del logo
              ),
              SizedBox(height: 32),
              // Título
              Text(
                'Regístrate', 
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
            ],
          ),
        ),
      ),
    );
  }
}
