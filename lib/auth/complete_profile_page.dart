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
  _CompleteProfilePageState createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String _selectedGender = '';

  // NUEVA VARIABLE PARA FECHA DE NACIMIENTO
  DateTime? _birthDate;

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

  Widget _genderSelector() {
    final actualTheme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text(kGeneroHombre),
          selected: _selectedGender == kGeneroHombre,
          backgroundColor: actualTheme.colorScheme.primary,
          selectedColor: actualTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == kGeneroHombre
                    ? BorderSide(
                      color: actualTheme.colorScheme.secondary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(
            color:
                _selectedGender == kGeneroHombre
                    ? actualTheme.colorScheme.secondary
                    : actualTheme.colorScheme.secondary,
          ),
          onSelected: (_) => setState(() => _selectedGender = kGeneroHombre),
        ),

        const SizedBox(width: 16),

        ChoiceChip(
          label: const Text(kGeneroMujer),
          selected: _selectedGender == kGeneroMujer,
          backgroundColor: actualTheme.colorScheme.primary,
          selectedColor: actualTheme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                _selectedGender == kGeneroMujer
                    ? BorderSide(
                      color: actualTheme.colorScheme.secondary,
                      width: 2,
                    )
                    : BorderSide.none,
          ),
          labelStyle: TextStyle(
            color:
                _selectedGender == kGeneroMujer
                    ? actualTheme.colorScheme.secondary
                    : actualTheme.colorScheme.secondary,
          ),
          onSelected: (_) => setState(() => _selectedGender = kGeneroMujer),
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

                ProfileField(
                  controller: _descriptionCtrl,
                  label: 'Descripción',
                  maxLines: 3,
                  validator: AuthValidators.descriptionValidator,
                ),

                const SizedBox(height: 8),

                // NUEVO CAMPO: FECHA DE NACIMIENTO
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
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.calendar_month_rounded,
                          size: 32,
                          color: actualTheme.colorScheme.onSurface,
                        ),
                        onPressed: _pickBirthDate,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                CustomButton(
                  text: _loading ? 'Guardando...' : 'Guardar perfil',
                  actualTheme: Theme.of(context),
                  onPressed: () {
                    // 1) Validamos campos y fecha
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

                    _submit();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          // CARGAMOS FECHA EXISTENTE
          if (data?['fecha_nac'] != null) {
            _birthDate = DateTime.parse(data!['fecha_nac']);
          }
        }
      });
    } catch (error) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando perfil: $error')));
    }
  }

  Future<void> _pickBirthDate() async {
    final actualTheme = Theme.of(context);
    final today = DateTime.now();
    final initial = _birthDate ?? DateTime(today.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: today,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      builder: (context, child) {
        return Localizations.override(
          context: context,
          child: Theme(
            data: actualTheme.copyWith(
              // Solo sobreescribimos el TextButtonTheme
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: actualTheme.colorScheme.secondary,
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final username = _usernameCtrl.text.trim();
    final user = supabase.auth.currentUser!;

    try {
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

      final dateNowIso = DateTime.now().toIso8601String();
      final data = {
        'auth_user_id': user.id,
        'nombre_usuario': username,
        'descripcion': _descriptionCtrl.text.trim(),
        'peso': double.tryParse(_weightCtrl.text),
        'estatura': double.tryParse(_heightCtrl.text),
        'genero': _selectedGender,
        'nombre': _nameCtrl.text.trim(),
        'apellidos': _lastnameCtrl.text.trim(),
        'fecha_nac': _birthDate!.toIso8601String().split('T').first, // AÑADIDO
        'created_at': dateNowIso,
        'updated_at': dateNowIso,
      };

      await supabase.from('usuarios').insert(data);

      if (!mounted) return;
      context.go(AppRoutes.home);
      showSuccessSnackBar(context, 'Registro completado con éxito');
    } on AuthException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, _mapProfileError(e.message));
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Traduce los mensajes de PostgREST a textos amigables
  String _mapProfileError(String apiMsg) {
    switch (apiMsg) {
      case 'duplicate key value violates unique constraint "usuarios_pkey"':
      case 'duplicate key value violates unique constraint "usuarios_auth_user_id_unique"':
        return 'Ya existe un perfil para este usuario.';
      case 'duplicate key value violates unique constraint "usuarios_nombre_usuario_key"':
        return 'El nombre de usuario ya está en uso.';
      case 'null value in column "nombre_usuario" violates not-null constraint':
        return 'El nombre de usuario es obligatorio.';
      case 'null value in column "nombre" violates not-null constraint':
        return 'El nombre es obligatorio.';
      case 'null value in column "apellidos" violates not-null constraint':
        return 'Los apellidos son obligatorios.';
      case 'null value in column "genero" violates not-null constraint':
        return 'Selecciona un género.';
      case 'null value in column "peso" violates not-null constraint':
        return 'El peso es obligatorio.';
      case 'null value in column "estatura" violates not-null constraint':
        return 'La estatura es obligatoria.';
      case 'null value in column "fecha_nac" violates not-null constraint':
        return 'Selecciona tu fecha de nacimiento.';
      case 'null value in column "created_at" violates not-null constraint':
      case 'null value in column "updated_at" violates not-null constraint':
        return 'Ha ocurrido un problema con las fechas del registro.';
      case 'invalid input syntax for type double precision':
        return 'Peso y estatura deben ser números válidos.';
      default:
        return 'No se pudo guardar el perfil: $apiMsg';
    }
  }

  // Helper para la visualización de la fecha
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
    final day = date.day;
    final month = meses[date.month - 1];
    final year = date.year;
    return '$day de $month de $year';
  }
}
