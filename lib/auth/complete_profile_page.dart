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

  // Controllers for editable fields
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController();
  final TextEditingController _genderCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _lastnameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();  // New controller for email

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser!;
    try {
      // Se obtiene el perfil de la base de datos
      final data = await supabase
          .from('usuarios')
          .select()
          .eq('auth_user_id', user.id)
          .maybeSingle();

      setState(() {
        _profile = data;
        _loading = false;  // Ya no está cargando
        if (_profile != null) {
          // Si el perfil existe, lo cargamos en los campos
          _usernameCtrl.text = data?['nombre_usuario'] ?? '';
          _descriptionCtrl.text = data?['descripcion'] ?? '';
          _weightCtrl.text = data?['peso']?.toString() ?? '';
          _heightCtrl.text = data?['estatura']?.toString() ?? '';
          _genderCtrl.text = data?['genero'] ?? '';
          _nameCtrl.text = data?['nombre'] ?? '';
          _lastnameCtrl.text = data?['apellidos'] ?? '';
          _emailCtrl.text = user.email ?? '';  // Pre-cargar el email del usuario autenticado
        }
      });
    } catch (error) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando perfil: $error')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = supabase.auth.currentUser!;

    if (_profile == null) {
      // Si no hay perfil, creamos uno nuevo
      final newUser = {
        'auth_user_id': user.id,
        'nombre_usuario': _usernameCtrl.text.trim(),
        'descripcion': _descriptionCtrl.text.trim(),
        'peso': double.tryParse(_weightCtrl.text),
        'estatura': double.tryParse(_heightCtrl.text),
        'genero': _genderCtrl.text.trim(),
        'nombre': _nameCtrl.text.trim(),
        'apellidos': _lastnameCtrl.text.trim(),
        'mail': _emailCtrl.text.trim(),  // Guardar el email
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      try {
        await supabase.from('usuarios').insert(newUser);
        setState(() => _loading = false);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $error')),
        );
      }
    } else {
      // Si ya existe el perfil, actualizamos los datos
      final updates = <String, dynamic>{};

      if (_usernameCtrl.text.isNotEmpty && _usernameCtrl.text != _profile?['nombre_usuario']) {
        updates['nombre_usuario'] = _usernameCtrl.text.trim();
      }
      if (_descriptionCtrl.text.isNotEmpty && _descriptionCtrl.text != _profile?['descripcion']) {
        updates['descripcion'] = _descriptionCtrl.text.trim();
      }
      if (_weightCtrl.text.isNotEmpty && double.tryParse(_weightCtrl.text) != _profile?['peso']) {
        updates['peso'] = double.tryParse(_weightCtrl.text);
      }
      if (_heightCtrl.text.isNotEmpty && double.tryParse(_heightCtrl.text) != _profile?['estatura']) {
        updates['estatura'] = double.tryParse(_heightCtrl.text);
      }
      if (_genderCtrl.text.isNotEmpty && _genderCtrl.text != _profile?['genero']) {
        updates['genero'] = _genderCtrl.text.trim();
      }
      if (_nameCtrl.text.isNotEmpty && _nameCtrl.text != _profile?['nombre']) {
        updates['nombre'] = _nameCtrl.text.trim();
      }
      if (_lastnameCtrl.text.isNotEmpty && _lastnameCtrl.text != _profile?['apellidos']) {
        updates['apellidos'] = _lastnameCtrl.text.trim();
      }
      if (_emailCtrl.text.isNotEmpty && _emailCtrl.text != _profile?['mail']) {
        updates['mail'] = _emailCtrl.text.trim();  // Actualizar el email
      }

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();
        try {
          await supabase
              .from('usuarios')
              .update(updates)
              .eq('auth_user_id', user.id);
          setState(() => _loading = false);
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (error) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar: $error')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      // Mientras esté cargando, mostrar un indicador
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Completa tu perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_profile == null || _profile!['nombre_usuario'] == null) ...[
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                  validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['descripcion'] == null) ...[
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['peso'] == null) ...[
                TextFormField(
                  controller: _weightCtrl,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['estatura'] == null) ...[
                TextFormField(
                  controller: _heightCtrl,
                  decoration: const InputDecoration(labelText: 'Estatura (cm)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['genero'] == null) ...[
                TextFormField(
                  controller: _genderCtrl,
                  decoration: const InputDecoration(labelText: 'Género'),
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['nombre'] == null) ...[
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['apellidos'] == null) ...[
                TextFormField(
                  controller: _lastnameCtrl,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                ),
                const SizedBox(height: 12),
              ],
              if (_profile == null || _profile!['mail'] == null) ...[
                TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Confirma el correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
