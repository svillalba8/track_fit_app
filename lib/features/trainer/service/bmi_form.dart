import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';
import 'package:track_fit_app/widgets/profield_center_field.dart';

class BmiForm extends StatefulWidget {
  final bool useMetric;
  const BmiForm({super.key, required this.useMetric});

  @override
  _BmiFormState createState() => _BmiFormState();
}

class _BmiFormState extends State<BmiForm> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  double? _result;
  bool _loadingProfile = false;
  double gridAspect = 1.1;

  void _updateGridAspect() {
    final formState = _formKey.currentState;
    if (formState == null) return;
    final isValid = formState.validate();
    setState(() {
      gridAspect = isValid ? 1.1 : 1.02;
    });
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
          
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
          if (_result != null) ...[
            const SizedBox(height: 12),
            CustomDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resultado: ${_result!.toStringAsFixed(1)} IMC',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                CustomIconButton(
                  icon: const Icon(Icons.copy_all_rounded),
                  actualTheme: theme,
                  onPressed: () {
                    final textToCopy = _result!.toStringAsFixed(1);
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Usuario no encontrado')));
      } else {
        setState(() {
          _weightCtrl.text = usuario.peso.toString();
          _heightCtrl.text = usuario.estatura.toString();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al cargar datos')));
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  void _calculateBmi() {
    if (!_formKey.currentState!.validate()) return;

    final rawWeight = double.parse(_weightCtrl.text);
    final rawHeight = double.parse(_heightCtrl.text);

    final weight = widget.useMetric ? rawWeight : rawWeight * 0.453592;
    final heightCm = widget.useMetric ? rawHeight : rawHeight * 2.54;

    final bmi = weight / pow(heightCm / 100, 2);

    setState(() => _result = bmi);
  }

  static String? emptyFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Obligatorio';
    }
    return null;
  }
}
