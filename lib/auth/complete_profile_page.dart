import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/validation/auth_validators.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

import '../core/constants.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key, String? userId});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // Estado de carga y datos del perfil
  bool _loading = true;

  // Campos del formulario
  String _selectedGender = '';
  DateTime? _birthDate;
  final _usernameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _lastnameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile(); // 1) Carga datos existentes al iniciar
  }

  /// Selector de género con ChoiceChips
  Widget _genderSelector() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text(kGeneroHombre),
          selected: _selectedGender == kGeneroHombre,
          onSelected: (_) => setState(() => _selectedGender = kGeneroHombre),
          backgroundColor: theme.colorScheme.primary,
          selectedColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == kGeneroHombre
                    ? BorderSide(color: theme.colorScheme.secondary, width: 2)
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(color: theme.colorScheme.secondary),
        ),
        const SizedBox(width: 16),
        ChoiceChip(
          label: const Text(kGeneroMujer),
          selected: _selectedGender == kGeneroMujer,
          onSelected: (_) => setState(() => _selectedGender = kGeneroMujer),
          backgroundColor: theme.colorScheme.primary,
          selectedColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == kGeneroMujer
                    ? BorderSide(color: theme.colorScheme.secondary, width: 2)
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(color: theme.colorScheme.secondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    if (_loading) {
      // 2) Indicador mientras carga perfil
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
                // Logo y título
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Image.asset(kLogoTrackFitBlancoMorado, height: 120),
                ),
                const Text(
                  'Completa tu perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Campos de texto reutilizando ProfileField
                ProfileField(
                  controller: _usernameCtrl,
                  label: 'Nombre de usuario',
                  validator: AuthValidators.usernameValidator,
                ),
                const SizedBox(height: 8),
                ProfileField(
                  controller: _nameCtrl,
                  label: 'Nombre',
                  validator: AuthValidators.nameValidator,
                ),
                const SizedBox(height: 8),
                ProfileField(
                  controller: _lastnameCtrl,
                  label: 'Apellidos',
                  validator: AuthValidators.lastnameValidator,
                ),
                const SizedBox(height: 8),
                ProfileField(
                  controller: _weightCtrl,
                  label: 'Peso (kg)',
                  keyboardType: TextInputType.number,
                  validator: AuthValidators.weightValidator,
                ),
                const SizedBox(height: 8),
                ProfileField(
                  controller: _heightCtrl,
                  label: 'Estatura (cm)',
                  keyboardType: TextInputType.number,
                  validator: AuthValidators.heightValidator,
                ),
                const SizedBox(height: 8),

                // Selector de género
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Género', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _genderSelector(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Descripción
                ProfileField(
                  controller: _descriptionCtrl,
                  label: 'Descripción',
                  maxLines: 3,
                  validator: AuthValidators.descriptionValidator,
                ),
                const SizedBox(height: 8),

                // Campo personalizado para fecha de nacimiento
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: actualTheme.colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          _birthDate == null
                              ? actualTheme.colorScheme.onSurface.withAlpha(
                                (0.4 * 255).round(),
                              )
                              : actualTheme.colorScheme.primary,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _birthDate == null
                              ? 'Fecha de nacimiento'
                              : formatSpanishDate(_birthDate!),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 32,
                          color: actualTheme.colorScheme.onSurface,
                        ),
                        onPressed: _pickBirthDate, // 3) Muestra date picker
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Botón de guardar perfil
                CustomButton(
                  text: _loading ? 'Guardando...' : 'Guardar perfil',
                  actualTheme: actualTheme,
                  onPressed: () {
                    // 4) Validación manual de fecha y campos
                    final errorMessage =
                        AuthValidators.usernameValidator(_usernameCtrl.text) ??
                        AuthValidators.nameValidator(_nameCtrl.text) ??
                        AuthValidators.lastnameValidator(_lastnameCtrl.text) ??
                        AuthValidators.weightValidator(_weightCtrl.text) ??
                        AuthValidators.heightValidator(_heightCtrl.text) ??
                        AuthValidators.genderValidator(_selectedGender) ??
                        AuthValidators.birthDateValidator(_birthDate);

                    if (errorMessage != null) {
                      showErrorSnackBar(context, errorMessage);
                      return;
                    }
                    _submit(); // 5) Envia datos al servidor
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 1) Lee perfil existente de Supabase y carga en los controladores
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
        _loading = false;
        if (data != null) {
          // Rellena controles con datos guardados
          _usernameCtrl.text = data['nombre_usuario'] ?? '';
          _descriptionCtrl.text = data['descripcion'] ?? '';
          _weightCtrl.text = data['peso']?.toString() ?? '';
          _heightCtrl.text = data['estatura']?.toString() ?? '';
          _nameCtrl.text = data['nombre'] ?? '';
          _lastnameCtrl.text = data['apellidos'] ?? '';
          _selectedGender = data['genero'] ?? '';
          if (data['fecha_nac'] != null) {
            _birthDate = DateTime.parse(data['fecha_nac']);
          }
        }
      });
    } catch (error) {
      setState(() => _loading = false);
      if (!mounted) return;
      showErrorSnackBar(context, 'Error cargando perfil: $error');
    }
  }

  /// 3) Muestra un date picker para escoger fecha de nacimiento
  Future<void> _pickBirthDate() async {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final initial = _birthDate ?? DateTime(today.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: today,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder:
          (ctx, child) => Theme(
            data: theme.copyWith(
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  /// 5) Envía datos actualizados a Supabase e inserta nuevo perfil
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = supabase.auth.currentUser!;
    final username = _usernameCtrl.text.trim();
    try {
      // Comprueba nombre de usuario único
      final existing =
          await supabase
              .from('usuarios')
              .select('auth_user_id')
              .eq('nombre_usuario', username)
              .maybeSingle();
      if (existing != null) {
        if (!mounted) return;
        showErrorSnackBar(context, 'El nombre de usuario ya está en uso');
        setState(() => _loading = false);
        return;
      }

      final nowIso = DateTime.now().toIso8601String();
      final data = {
        'auth_user_id': user.id,
        'nombre_usuario': username,
        'descripcion': _descriptionCtrl.text.trim(),
        'peso': double.tryParse(_weightCtrl.text),
        'estatura': double.tryParse(_heightCtrl.text),
        'genero': _selectedGender,
        'nombre': _nameCtrl.text.trim(),
        'apellidos': _lastnameCtrl.text.trim(),
        'fecha_nac': _birthDate!.toIso8601String().split('T').first,
        'created_at': nowIso,
        'updated_at': nowIso,
      };
      await supabase.from('usuarios').insert(data);
      if (!mounted) return;
      context.go(AppRoutes.home);
      showSuccessSnackBar(context, 'Registro completado con éxito');
    } on AuthException catch (e) {
      showErrorSnackBar(context, _mapProfileError(e.message));
    } catch (e) {
      showErrorSnackBar(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Traduce errores de PostgREST a mensajes amigables
  String _mapProfileError(String apiMsg) {
    switch (apiMsg) {
      case 'duplicate key value violates unique constraint "usuarios_nombre_usuario_key"':
        return 'El nombre de usuario ya está en uso.';
      case 'null value in column "fecha_nac" violates not-null constraint':
        return 'Selecciona tu fecha de nacimiento.';
      // …otros mapeos…
      default:
        return 'No se pudo guardar el perfil: $apiMsg';
    }
  }

  /// Formatea fecha a 'día de mes de año' en español
  String formatSpanishDate(DateTime date) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${meses[date.month - 1]} de ${date.year}';
  }
}
