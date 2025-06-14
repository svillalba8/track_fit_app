import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart'; // getIt para DI
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';
import 'package:track_fit_app/widgets/profield_center_field.dart';
import 'package:track_fit_app/widgets/profile_selector.dart';

/// Formulario para calcular porcentaje de grasa corporal:
/// - Permite cargar datos del perfil
/// - Seleccionar sexo y rellenar edad, peso y altura
/// - Valida campos y ajusta diseño antes de calcular
class BodyFatForm extends StatefulWidget {
  final bool useMetric; // true = kg/cm, false = lb/in

  const BodyFatForm({super.key, required this.useMetric});

  @override
  State<BodyFatForm> createState() => _BodyFatFormState();
}

class _BodyFatFormState extends State<BodyFatForm> {
  final _formKey = GlobalKey<FormState>();
  String _gender = kGeneroMujer; // Sexo seleccionado
  final opcionesSexo = [kGeneroHombre, kGeneroMujer]; // Opciones de sexo

  final _ageCtrl = TextEditingController(); // Edad
  final _weightCtrl = TextEditingController(); // Peso
  final _heightCtrl = TextEditingController(); // Altura

  double? _result; // Porcentaje calculado
  bool _loadingProfile = false;
  double gridAspect = 1.1; // Ajusta altura de celdas según validación

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  /// Ajusta [gridAspect] para expandir/contraer las celdas si faltan datos
  void _updateGridAspect() {
    final valid = _formKey.currentState?.validate() == true;
    setState(() => gridAspect = valid ? 1.1 : 1.02);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Botón para cargar datos del usuario autenticado
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
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),

          const SizedBox(height: 12),

          // Grid 2x2 con selector de sexo y campos de texto
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: gridAspect,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Selector de sexo (Choice entre Hombre/Mujer)
              ProfileSelector(
                label: 'Sexo',
                value: _gender,
                items: opcionesSexo,
                onChanged: (val) => setState(() => _gender = val),
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
                label: widget.useMetric ? 'Peso (kg)' : 'Peso (lb)',
                validator: emptyFieldValidator,
              ),
              // Altura
              ProfileCenterField(
                controller: _heightCtrl,
                label: widget.useMetric ? 'Altura (cm)' : 'Altura (in)',
                validator: emptyFieldValidator,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Botón para calcular % de grasa (primero ajusta aspecto)
          ElevatedButton.icon(
            onPressed: () {
              _updateGridAspect();
              _calculateBodyFat();
            },
            label: const Text('Calcular % Grasa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),

          // Muestra el resultado con opción de copiar al portapapeles
          if (_result != null) ...[
            const SizedBox(height: 12),
            CustomDivider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado: ${_result!.toStringAsFixed(1)}% de grasa',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomIconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  actualTheme: theme,
                  onPressed: () {
                    final textToCopy =
                        '${_result!.toStringAsFixed(1)}% de grasa';
                    Clipboard.setData(ClipboardData(text: textToCopy));
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

  /// Carga datos de sexo, edad, peso y altura desde el perfil Supabase
  Future<void> _loadProfile() async {
    // Antes de setState inicial, validamos mounted
    if (!mounted) return;
    setState(() => _loadingProfile = true);

    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    final userService = getIt<UsuarioService>();

    if (authUser == null) {
      if (!mounted) return;
      showNeutralSnackBar(context, 'No estás autenticado');
    } else {
      try {
        final usuario = await userService.fetchUsuarioByAuthId(authUser.id);

        // Protección tras await
        if (!mounted) return;

        if (usuario == null) {
          showNeutralSnackBar(context, 'Usuario no encontrado');
        } else {
          // Actualizamos estado dentro de setState protegido
          setState(() {
            _gender =
                [kGeneroHombre, kGeneroMujer].contains(usuario.genero)
                    ? usuario.genero
                    : kGeneroMujer;
            _ageCtrl.text = usuario.getEdad().toString();
            _weightCtrl.text = usuario.peso.toString();
            _heightCtrl.text = usuario.estatura.toString();
          });
        }
      } catch (_) {
        if (!mounted) return;
        showErrorSnackBar(context, 'Error al cargar datos');
      }
    }

    // Finalmente, desactivamos el loading si seguimos montados
    if (!mounted) return;
    setState(() => _loadingProfile = false);
  }

  /// Calcula el % de grasa según fórmula simple basada en IMC y edad
  void _calculateBodyFat() {
    if (!_formKey.currentState!.validate()) return;
    final age = double.parse(_ageCtrl.text);
    final rawW = double.parse(_weightCtrl.text);
    final rawH = double.parse(_heightCtrl.text);
    final weight = widget.useMetric ? rawW : rawW * 0.453592;
    final heightCm = widget.useMetric ? rawH : rawH * 2.54;
    final bmi = weight / pow(heightCm / 100, 2);
    // Fórmula diferenciada por sexo
    final bf =
        (_gender == kGeneroHombre)
            ? 1.2 * bmi + 0.23 * age - 16.2
            : 1.2 * bmi + 0.23 * age - 5.4;
    setState(() => _result = bf);
  }

  /// Validador genérico para campos obligatorios
  static String? emptyFieldValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null;
}
