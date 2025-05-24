import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/data/di.dart'; // getIt
import 'package:track_fit_app/services/usuario_service.dart'; // UsuarioService

class BodyFatForm extends StatefulWidget {
  final bool useMetric;
  const BodyFatForm({super.key, required this.useMetric});

  @override
  _BodyFatFormState createState() => _BodyFatFormState();
}

class _BodyFatFormState extends State<BodyFatForm> {
  final _formKey = GlobalKey<FormState>();
  String _gender = kGeneroMujer;
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  double? _result;
  bool _loadingProfile = false;

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);

    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    final userService = getIt<UsuarioService>();

    if (authUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No estás autenticado')));
      setState(() => _loadingProfile = false);
      return;
    }

    try {
      final usuario = await userService.fetchUsuarioByAuthId(authUser.id);
      if (usuario == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no encontrado')));
      } else {
        // Rellenar solo los campos que necesitas
        setState(() {
          _gender = usuario.genero;
          //_ageCtrl.text = usuario.edad.toString();
          _weightCtrl.text = usuario.peso.toString();
          _heightCtrl.text = usuario.estatura.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cargar datos')));
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  void _calculateBodyFat() {
    if (!_formKey.currentState!.validate()) return;

    final age = double.parse(_ageCtrl.text);
    final rawWeight = double.parse(_weightCtrl.text);
    final rawHeight = double.parse(_heightCtrl.text);

    // Convierte según unidades
    final weight = widget.useMetric ? rawWeight : rawWeight * 0.453592;
    final height = widget.useMetric ? rawHeight : rawHeight * 2.54;

    // Cálculo de ejemplo (sustituye tus constantes reales)
    final bmi = weight / pow(height / 100, 2);
    final bf =
        (_gender == kGeneroHombre)
            ? 1.2 * bmi + 0.23 * age - 16.2
            : 1.2 * bmi + 0.23 * age - 5.4;

    setState(() => _result = bf);
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heightLabel = widget.useMetric ? 'cm' : 'in';
    final weightLabel = widget.useMetric ? 'kg' : 'lb';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón para cargar datos del usuario
          ElevatedButton.icon(
            onPressed: _loadingProfile ? null : _loadProfile,
            icon:
                _loadingProfile
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.download_rounded),
            label: const Text('Cargar mis datos'),
          ),
          const SizedBox(height: 16),

          // Selector Sexo
          DropdownButtonFormField<String>(
            value: _gender,
            items:
                [kGeneroMujer, kGeneroHombre]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
            decoration: const InputDecoration(labelText: 'Sexo'),
            onChanged: (v) => setState(() => _gender = v!),
          ),
          const SizedBox(height: 12),

          // Edad
          TextFormField(
            controller: _ageCtrl,
            decoration: const InputDecoration(labelText: 'Edad'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 12),

          // Peso
          TextFormField(
            controller: _weightCtrl,
            decoration: InputDecoration(labelText: 'Peso ($weightLabel)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 12),

          // Altura
          TextFormField(
            controller: _heightCtrl,
            decoration: InputDecoration(labelText: 'Altura ($heightLabel)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Obligatorio' : null,
          ),
          const SizedBox(height: 20),

          // Botón calcular
          ElevatedButton(
            onPressed: _calculateBodyFat,
            child: const Text('Calcular % Grasa'),
          ),

          if (_result != null) ...[
            const SizedBox(height: 16),
            Text(
              'Resultado: ${_result!.toStringAsFixed(1)}% de grasa',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }
}
