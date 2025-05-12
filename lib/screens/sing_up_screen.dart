import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track_fit_app/blocs/auth_bloc.dart';
import 'package:track_fit_app/routes/app_routes.dart';
=======
import 'package:track_fit_app/screens/login_screen.dart';
>>>>>>> origin/pantalla_login_singin
import 'package:track_fit_app/utils/constants.dart';
import 'package:track_fit_app/services/validation_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
<<<<<<< HEAD
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
=======
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  SignUpScreen({super.key});
>>>>>>> origin/pantalla_login_singin

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: kPrimaryColor,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccessRegister) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildRegistrationForm();
        },
=======
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
>>>>>>> origin/pantalla_login_singin
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
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _submitForm,
            child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
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
  }
}