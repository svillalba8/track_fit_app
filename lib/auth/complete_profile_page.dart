import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/widgets/custom_button.dart';
import '../utils/constants.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser!;
    try {
      final data =
          await supabase
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
          _selectedGender = _genderCtrl.text;
        }
      });
    } catch (error) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando perfil: $error')));
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
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (_profile == null) {
      dataToSave['created_at'] = DateTime.now().toIso8601String();
      try {
        await supabase.from('usuarios').insert(dataToSave);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $error')));
      }
    } else {
      try {
        await supabase
            .from('usuarios')
            .update(dataToSave)
            .eq('auth_user_id', user.id);
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al actualizar: $error')));
      }
    }

    setState(() => _loading = false);
  }

  Widget _genderSelector() {
    final actualTheme = Theme.of(context);
    const hombreText = 'Hombre';
    const mujerText = 'Mujer';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text(hombreText),
          selected: _selectedGender == hombreText,
          backgroundColor: actualTheme.colorScheme.tertiary,
          selectedColor: actualTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == hombreText
                    ? BorderSide(
                      color: actualTheme.colorScheme.secondary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(
            color:
                _selectedGender == hombreText
                    ? actualTheme.colorScheme.onPrimary
                    : actualTheme.colorScheme.onSurface,
          ),
          onSelected: (_) {
            setState(() {
              _selectedGender = hombreText;
            });
          },
        ),
        const SizedBox(width: 16),

        ChoiceChip(
          label: const Text(mujerText),
          backgroundColor: actualTheme.colorScheme.tertiary,
          selectedColor: actualTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == mujerText
                    ? BorderSide(
                      color: actualTheme.colorScheme.secondary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(
            color:
                _selectedGender == mujerText
                    ? actualTheme.colorScheme.onPrimary
                    : actualTheme.colorScheme.onSurface,
          ),
          selected: _selectedGender == mujerText,
          onSelected: (_) {
            setState(() {
              _selectedGender = mujerText;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: actualTheme.colorScheme.primary,
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
                  child: Image.asset(kLogoTrackFitBlancoMorado, height: 120),
                ),
                const Text(
                  'Completa tu perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _usernameCtrl,
                    cursorColor: actualTheme.colorScheme.secondary,
                    decoration: InputDecoration(
                      labelText: 'Nombre de usuario',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    validator: (v) => v!.isEmpty ? 'Obligatorio' : null,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _nameCtrl,
                    cursorColor: actualTheme.colorScheme.secondary,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _lastnameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration: InputDecoration(
                      labelText: 'Peso (kg)',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _heightCtrl,
                    decoration: InputDecoration(
                      labelText: 'Estatura (cm)',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Género', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _genderSelector(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: _descriptionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: actualTheme.textTheme.bodyMedium?.copyWith(
                        color: actualTheme.colorScheme.secondary,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Guardar perfil',
                  actualTheme: Theme.of(context),
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
