import 'package:flutter/material.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class EditUserPage extends StatefulWidget {
  final UsuarioModel usuario;

  const EditUserPage({Key? key, required this.usuario}) : super(key: key);

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreUsuarioController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _pesoController = TextEditingController();
  final _estaturaController = TextEditingController();
  bool _isSaving = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nombreUsuarioController.text = widget.usuario.nombreUsuario;
    _descripcionController.text = widget.usuario.descripcion ?? '';
    _pesoController.text = widget.usuario.peso.toString();
    _estaturaController.text = widget.usuario.estatura.toString();
  }

  @override
  void dispose() {
    _nombreUsuarioController.dispose();
    _descripcionController.dispose();
    _pesoController.dispose();
    _estaturaController.dispose();
    super.dispose();
  }

  void _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedUser = widget.usuario.copyWith(
        nombreUsuario: _nombreUsuarioController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        peso: double.parse(_pesoController.text.trim()),
        estatura: double.parse(_estaturaController.text.trim()),
      );

      final api = ApiService(Supabase.instance.client);
      await api.updateUsuario(updatedUser);

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
    } catch (e) {
      showErrorSnackBar(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos personales'),
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                ProfileField(
                  controller: _nombreUsuarioController,
                  label: 'Nombre de usuario',
                  validator: AuthValidators.usernameValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                ProfileField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  validator: AuthValidators.descriptionValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                ProfileField(
                  controller: _pesoController,
                  label: 'Peso (Kg)',
                  validator: AuthValidators.weightValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                ProfileField(
                  controller: _estaturaController,
                  label: 'Estatura (cm)',
                  validator: AuthValidators.heightValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  CustomButton(
                    text: _isSaving ? 'Cargando...' : 'Guardar cambios',
                    actualTheme: theme,
                    onPressed: _guardarCambios,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
