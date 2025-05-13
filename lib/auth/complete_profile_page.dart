import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({Key? key}) : super(key: key);

  @override
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String _selectedGender = '';

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _genderCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _lastnameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser!;
    try {
      final data = await supabase
          .from('usuarios')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      setState(() {
        _profile = data;
        _loading = false;

        if (_profile != null) {
          _usernameCtrl.text = data?['nombre_usuario'] ?? '';
          _descriptionCtrl.text = data?['descripcion'] ?? '';
          _weightCtrl.text = data?['peso']?.toString() ?? '';
          _heightCtrl.text = data?['estatura']?.toString() ?? '';
          _genderCtrl.text = data?['genero'] ?? '';
          _nameCtrl.text = data?['nombre'] ?? '';
          _lastnameCtrl.text = data?['apellidos'] ?? '';
          _emailCtrl.text = user.email ?? '';
          _selectedGender = _genderCtrl.text;
        }
      });
    } catch (error) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando perfil: $error')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final user = supabase.auth.currentUser!;

    final dataToSave = {
      'auth_user_id': user.id,
      'nombre_usuario': _usernameCtrl.text.trim(),
      'descripcion': _descriptionCtrl.text.trim(),
      'peso': double.tryParse(_weightCtrl.text),
      'estatura': double.tryParse(_heightCtrl.text),
      'genero': _selectedGender,
      'nombre': _nameCtrl.text.trim(),
      'apellidos': _lastnameCtrl.text.trim(),
      'mail': _emailCtrl.text.trim(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (_profile == null) {
      dataToSave['created_at'] = DateTime.now().toIso8601String();
      try {
        await supabase.from('usuarios').insert(dataToSave);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error')),
        );
      }
    } else {
      try {
        await supabase
            .from('usuarios')
            .update(dataToSave)
            .eq('auth_user_id', user.id);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $error')),
        );
      }
    }

    setState(() => _loading = false);
  }

  Widget _genderSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Hombre'),
          selected: _selectedGender == 'Hombre',
          onSelected: (_) {
            setState(() {
              _selectedGender = 'Hombre';
            });
          },
        ),
        const SizedBox(width: 16),
        ChoiceChip(
          label: const Text('Mujer'),
          selected: _selectedGender == 'Mujer',
          onSelected: (_) {
            setState(() {
              _selectedGender = 'Mujer';
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Logo arriba
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(
                    'assets/logo.png', // Asegúrate de tener el logo en assets
                    height: 80,
                  ),
                ),
                const Text(
                  'Completa tu perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                  validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Confirma el correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _lastnameCtrl,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _heightCtrl,
                  decoration: const InputDecoration(labelText: 'Estatura (cm)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Género', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 8),
                _genderSelector(),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('Guardar perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
