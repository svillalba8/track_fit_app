import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart'; // getIt
import 'package:track_fit_app/widgets/profield_center_field.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';
import 'package:track_fit_app/widgets/profile_selector.dart'; // UsuarioService

class BodyFatForm extends StatefulWidget {
  final bool useMetric;
  const BodyFatForm({super.key, required this.useMetric});

  @override
  State<BodyFatForm> createState() => _BodyFatFormState();
}

class _BodyFatFormState extends State<BodyFatForm> {
  final _formKey = GlobalKey<FormState>();
  String _gender = kGeneroMujer;
  final opcionesSexo = [kGeneroHombre, kGeneroMujer];
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  double? _result;
  bool _loadingProfile = false;
  double gridAspect = 1.1; // ratio por defecto: ancho ÷ alto

  void _updateGridAspect() {
    // Si el form aún no está inicializado, salimos
    final formState = _formKey.currentState;
    if (formState == null) return;

    // Hacemos una validación *sin* mostrar SnackBars:
    final isValid = formState.validate();
    setState(() {
      gridAspect = isValid ? 1.1 : 1.02; // NO TOCAR
    });
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
    final ThemeData actualTheme = Theme.of(context);

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
            style: ElevatedButton.styleFrom(
              backgroundColor: actualTheme.colorScheme.secondary,
              foregroundColor: actualTheme.colorScheme.primary,
            ),
          ),

          // Grid 2x2 limpio:
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: gridAspect,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Selector Sexo
              ProfileSelector(
                label: 'Sexo',
                value: _gender,
                items: opcionesSexo,
                onChanged: (val) {
                  setState(() => _gender = val);
                },
              ),

              // Edad
              ProfileCenterField(
                controller: _ageCtrl,
                label: 'Edad',
                validator: emptyFieldValidator,
              ),

              // Peso
              ProfileCenterField(
                controller: _weightCtrl,
                label: 'Peso ()',
                validator: emptyFieldValidator,
              ),

              // Altura
              ProfileCenterField(
                controller: _heightCtrl,
                label: 'Altura ()',
                validator: emptyFieldValidator,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Botón calcular
          ElevatedButton.icon(
            onPressed: () {
              _updateGridAspect();
              _calculateBodyFat();
            },
            label: const Text('Calcular % Grasa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: actualTheme.colorScheme.secondary,
              foregroundColor: actualTheme.colorScheme.primary,
            ),
          ),

          if (_result != null) ...[
            const SizedBox(height: 12),
            CustomDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado: ${_result!.toStringAsFixed(1)}% de grasa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomIconButton(
                  icon: Icon(Icons.copy_all_rounded),
                  actualTheme: actualTheme,
                  onPressed: () {
                    // 1) Formamos el texto a copiar
                    final textToCopy =
                        '${_result!.toStringAsFixed(1)}% de grasa';
                    // 2) Lo guardamos en el portapapeles
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    // 3) Mensaje corto al usuario
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Resultado copiado')),
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

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
        if (!mounted) return;
        showNeutralSnackBar(context, 'Usuario no encontrado');
      } else {
        // Rellenar solo los campos que necesitas
        setState(() {
          _gender =
              [kGeneroMujer, kGeneroHombre].contains(usuario.genero)
                  ? usuario.genero
                  : kGeneroMujer;
          _ageCtrl.text = usuario.getEdad().toString();
          _weightCtrl.text = usuario.peso.toString();
          _heightCtrl.text = usuario.estatura.toString();
        });
      }
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error al cargar datos');
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

  /// Valida que un campo no esté vacío.
  static String? emptyFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obligatorio';
    }
    return null;
  }
}
