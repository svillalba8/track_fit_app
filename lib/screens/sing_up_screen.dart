import 'package:flutter/material.dart';
import 'package:track_fit_app/screens/login_screen.dart';
import 'package:track_fit_app/utils/constants.dart';
import 'package:track_fit_app/services/validation_service.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnamesController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _surnamesController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

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
                // controller: _confirmPasswordController,  OJO 
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmar contraseña'),
              ),
              SizedBox(height: 32),
              // Botón para crear cuenta
              CustomButton(
                text: 'Crear cuenta',
                colorTheme: Theme.of(context).primaryColor,
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

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) => ValidationService.isCorrectFormat(
                value!, TextFormat.email)
                ? null
                : 'Email inválido',
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: (value) => value != null && value.length >= 6
                ? null
                : 'Mínimo 6 caracteres',
            decoration: const InputDecoration(labelText: 'Contraseña'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            validator: (value) =>
            value!.isEmpty ? 'Campo obligatorio' : null,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _surnamesController,
            validator: (value) =>
            value!.isEmpty ? 'Campo obligatorio' : null,
            decoration: const InputDecoration(labelText: 'Apellidos'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isNotEmpty && int.tryParse(value) != null
                ? null
                : 'Edad inválida',
            decoration: const InputDecoration(labelText: 'Edad'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isNotEmpty && double.tryParse(value) != null
                ? null
                : 'Peso inválido',
            decoration: const InputDecoration(labelText: 'Peso (kg)'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isNotEmpty && double.tryParse(value) != null
                ? null
                : 'Altura inválida',
            decoration: const InputDecoration(labelText: 'Altura (cm)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            items: ['Masculino', 'Femenino', 'Otro'].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedGender = value),
            validator: (value) => value == null ? 'Selecciona un género' : null,
            decoration: const InputDecoration(labelText: 'Género'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,  //OJO 
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: /*_submitForm*/null, //OJO
            child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /*void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(OnRegisterEvent(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        surnames: _surnamesController.text.trim(),
        age: int.parse(_ageController.text),
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        gender: _selectedGender!,
        userName: _nameController.text.trim(),
        status: 'active',
        description: '',
      ));
    }
  }*/
}