// sign_up_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_bloc.dart';
import '../services/validation_service.dart';

class SignUpScreen extends StatefulWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Cuenta')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
          if (state is AuthSuccessRegister) {
            Navigator.pushReplacementNamed(context, '/login');
          }

        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _emailController,
            validator: (value) => ValidationService.isCorrectFormat(value!, TextFormat.email)
                ? null
                : 'Email inválido',
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            validator: (value) => value != null && value.length >= 6
                ? null
                : 'La contraseña debe tener al menos 6 caracteres',
            decoration: InputDecoration(labelText: 'Contraseña'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            validator: (value) => value != null && value.isNotEmpty
                ? null
                : 'Introduce tu nombre',
            decoration: InputDecoration(labelText: 'Nombre'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _surnamesController,
            validator: (value) => value != null && value.isNotEmpty
                ? null
                : 'Introduce tus apellidos',
            decoration: InputDecoration(labelText: 'Apellidos'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            validator: (value) => value != null && int.tryParse(value) != null
                ? null
                : 'Introduce tu edad correctamente',
            decoration: InputDecoration(labelText: 'Edad'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            validator: (value) => value != null && double.tryParse(value) != null
                ? null
                : 'Introduce tu peso correctamente',
            decoration: InputDecoration(labelText: 'Peso (kg)'),
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            validator: (value) => value != null && double.tryParse(value) != null
                ? null
                : 'Introduce tu altura correctamente',
            decoration: InputDecoration(labelText: 'Altura (cm)'),
          ),
          SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGender,
            items: ['Masculino', 'Femenino', 'Otro'].map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
            validator: (value) => value != null
                ? null
                : 'Selecciona un género',
            decoration: InputDecoration(labelText: 'Género'),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Registrarse'),
          ),
        ],
      ),
    );
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_ageController.text.isEmpty ||
          _weightController.text.isEmpty ||
          _heightController.text.isEmpty ||
          _selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, rellena todos los campos')),
        );
        return;
      }

      context.read<AuthBloc>().add(OnRegisterEvent(
        userName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        surnames: _surnamesController.text,
        age: int.tryParse(_ageController.text) ?? 0, // usa tryParse para evitar crash
        weight: double.tryParse(_weightController.text) ?? 0.0,
        height: double.tryParse(_heightController.text) ?? 0.0,
        gender: _selectedGender!,
        status: 'active',
        description: '',
      ));
    }
  }

}