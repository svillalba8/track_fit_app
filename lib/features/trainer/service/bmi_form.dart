import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';
import 'package:track_fit_app/widgets/profield_center_field.dart';

/// Formulario para calcular el IMC:
/// - Permite cargar peso/altura del perfil
/// - Valida campos y ajusta aspecto de la cuadrícula
/// - Calcula y muestra el resultado
class BmiForm extends StatefulWidget {
  final bool useMetric; // true = kg/cm, false = lb/in

  const BmiForm({super.key, required this.useMetric});

  @override
  State<BmiForm> createState() => _BmiFormState();
}

class _BmiFormState extends State<BmiForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  double? _result; // Resultado del cálculo de IMC
  bool _loadingProfile = false;
  double gridAspect = 1.1; // Ratio de aspecto de la GridView

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  /// Ajusta [gridAspect] para expandir o contraer las cajas según validación
  void _updateGridAspect() {
    final valid = _formKey.currentState?.validate() == true;
    setState(() {
      gridAspect = valid ? 1.1 : 1.02;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Botón de carga de datos desde perfil
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

          // 2) Grid con campos de peso y altura
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: gridAspect,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ProfileCenterField(
                controller: _weightCtrl,
                label: widget.useMetric ? 'Peso (kg)' : 'Peso (lb)',
                validator: emptyFieldValidator,
              ),
              ProfileCenterField(
                controller: _heightCtrl,
                label: widget.useMetric ? 'Altura (cm)' : 'Altura (in)',
                validator: emptyFieldValidator,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 3) Botón para calcular IMC (ajusta cuadrícula antes)
          ElevatedButton.icon(
            onPressed: () {
              _updateGridAspect();
              _calculateBmi();
            },
            icon: const Icon(Icons.monitor_weight_rounded),
            label: const Text('Calcular IMC'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),

          // 4) Muestra el resultado si ya se calculó
          if (_result != null) ...[
            const SizedBox(height: 12),
            CustomDivider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado: ${_result!.toStringAsFixed(1)} IMC',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                // Copia al portapapeles
                CustomIconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  actualTheme: theme,
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: _result!.toStringAsFixed(1)),
                    );
                    showNeutralSnackBar(context, 'Resultado copiado');
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 4) Carga peso/altura del perfil del usuario autenticado
  Future<void> _loadProfile() async {
    // Evitamos llamar setState si el widget ya no está montado
    if (!mounted) return;

    setState(() => _loadingProfile = true);

    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    final userService = getIt<UsuarioService>();

    if (authUser == null) {
      // Comprobamos de nuevo antes de usar context
      if (!mounted) return;
      showNeutralSnackBar(context, 'No estás autenticado');
    } else {
      try {
        final usuario = await userService.fetchUsuarioByAuthId(authUser.id);

        // Tras el await, volver a proteger cualquier uso de estado o context
        if (!mounted) return;

        if (usuario == null) {
          showNeutralSnackBar(context, 'Usuario no encontrado');
        } else {
          _weightCtrl.text = usuario.peso.toString();
          _heightCtrl.text = usuario.estatura.toString();
        }
      } catch (_) {
        if (!mounted) return;
        showErrorSnackBar(context, 'Error al cargar datos');
      }
    }

    // Finalmente, bajamos el indicador de carga
    if (!mounted) return;
    setState(() => _loadingProfile = false);
  }

  /// 5) Valida campos, convierte unidades y calcula el IMC
  void _calculateBmi() {
    if (!_formKey.currentState!.validate()) return;
    final w = double.parse(_weightCtrl.text);
    final h = double.parse(_heightCtrl.text);
    final weight = widget.useMetric ? w : w * 0.453592;
    final heightCm = widget.useMetric ? h : h * 2.54;
    final bmi = weight / pow(heightCm / 100, 2);
    setState(() => _result = bmi);
  }

  /// Validador genérico para campos obligatorios
  static String? emptyFieldValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Obligatorio' : null;
}
