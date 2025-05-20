import 'package:flutter/material.dart';
import 'package:track_fit_app/models/usuario_model.dart';
import 'package:track_fit_app/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar datos personales')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreUsuarioController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de usuario',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Introduce un nombre de usuario';
                    }
                    if (value.trim().length < 5) {
                      return 'Debe tener al menos 5 caracteres';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 2,
                ),
                TextFormField(
                  controller: _pesoController,
                  decoration: const InputDecoration(labelText: 'Peso (kg)'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final peso = double.tryParse(value ?? '');
                    if (peso == null || peso <= 0) {
                      return 'Introduce un peso válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _estaturaController,
                  decoration: const InputDecoration(labelText: 'Estatura (cm)'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final estatura = double.tryParse(value ?? '');
                    if (estatura == null || estatura <= 0) {
                      return 'Introduce una estatura válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : _guardarCambios,
                  child:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
