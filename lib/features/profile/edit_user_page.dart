import 'package:flutter/material.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

/// Página para ver y editar los datos personales del usuario.
/// - Muestra campos en modo lectura por defecto.
/// - Al pulsar el icono de editar, habilita los campos y muestra botón de guardar.
class EditUserPage extends StatefulWidget {
  final UsuarioModel usuario;

  const EditUserPage({super.key, required this.usuario});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreUsuarioController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _pesoController;
  late final TextEditingController _estaturaController;

  bool _isSaving = false; // Indica si se está guardando
  bool _isEditing = false; // Controla si los campos están editables
  late final UsuarioModel usuario;

  @override
  void initState() {
    super.initState();
    usuario = widget.usuario;
    // Inicializa controladores con datos actuales
    _nombreUsuarioController = TextEditingController(
      text: usuario.nombreUsuario,
    );
    _descripcionController = TextEditingController(
      text: usuario.descripcion ?? '',
    );
    _pesoController = TextEditingController(text: usuario.peso.toString());
    _estaturaController = TextEditingController(
      text: usuario.estatura.toString(),
    );
  }

  @override
  void dispose() {
    // Libera recursos de los controladores
    _nombreUsuarioController.dispose();
    _descripcionController.dispose();
    _pesoController.dispose();
    _estaturaController.dispose();
    super.dispose();
  }

  /// Valida el formulario y envía los cambios a Supabase via UsuarioService.
  /// - Muestra un SnackBar en caso de error.
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Crea una copia actualizada del modelo
      final updatedUser = usuario.copyWith(
        nombreUsuario: _nombreUsuarioController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        peso: double.parse(_pesoController.text.trim()),
        estatura: double.parse(_estaturaController.text.trim()),
      );
      await getIt<UsuarioService>().updateUsuario(updatedUser);
      if (!mounted) return;
      // Retorna el usuario actualizado al llamador
      Navigator.pop(context, updatedUser);
    } catch (e) {
      showErrorSnackBar(context, 'Error al guardar cambios');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos personales'),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            // Alterna entre modo lectura y edición
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar',
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Campo: nombre de usuario
                ProfileField(
                  controller: _nombreUsuarioController,
                  label: 'Nombre de usuario',
                  validator: AuthValidators.usernameValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                // Campo: descripción
                ProfileField(
                  controller: _descripcionController,
                  label: 'Descripción',
                  validator: AuthValidators.descriptionValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                // Campo: peso
                ProfileField(
                  controller: _pesoController,
                  label: 'Peso (Kg)',
                  validator: AuthValidators.weightValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 12),
                // Campo: estatura
                ProfileField(
                  controller: _estaturaController,
                  label: 'Estatura (cm)',
                  validator: AuthValidators.heightValidator,
                  readOnly: !_isEditing,
                ),
                const SizedBox(height: 24),
                if (_isEditing)
                  // Botón para guardar cambios, solo visible en edición
                  CustomButton(
                    text: _isSaving ? 'Guardando...' : 'Guardar cambios',
                    actualTheme: actualTheme,
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
