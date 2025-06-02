import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/trainer/widgets/option_stepper.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/profield_center_field.dart';
import 'package:track_fit_app/widgets/profile_selector.dart';

class MacrosForm extends StatefulWidget {
  final bool useMetric;
  final VoidCallback? onCalculated;
  const MacrosForm({super.key, required this.useMetric, this.onCalculated});

  @override
  _MacrosFormState createState() => _MacrosFormState();
}

class _MacrosFormState extends State<MacrosForm> {
  final _formKey = GlobalKey<FormState>();
  bool _showQuestions = false;

  String _gender = kGeneroMujer;
  final opcionesSexo = [kGeneroHombre, kGeneroMujer];
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();

  final nivelesActividad = [
    'Actividad sedentaria: poco o ningún ejercicio',
    'Actividad ligera: ejercicio ligero o deporte 1-3 días/semana',
    'Actividad moderada: ejercicio moderado o deporte 3-5 días/semana',
    'Actividad alta: ejercicio intenso o deporte 6-7 días/semana',
    'Actividad muy alta: ejercicio muy intenso o doble entrenamiento diario',
  ];
  String? _activityLevel;

  final objetivos = ['Mantener peso', 'Ganar masa muscular', 'Perder grasa'];
  String? _goal;

  final superavitOptions = [
    'Selecciona una opción',
    'Superávit ligero',
    'Superávit moderado',
    'Superávit agresivo',
    'Superávit muy agresivo',
  ];
  String? _calorieSurplus = 'Selecciona una opción';

  double? _calories;

  double? _minCarb, _maxCarb;
  double? _minProtein, _maxProtein;
  double? _minFat, _maxFat;

  bool _loadingProfile = false;

  bool get _step1Valid {
    return _gender.isNotEmpty &&
        _ageCtrl.text.isNotEmpty &&
        _weightCtrl.text.isNotEmpty &&
        _heightCtrl.text.isNotEmpty;
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bodyFatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final actualtheme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cargar datos del usuario
          if (!_showQuestions) ...[
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),

          if (!_showQuestions) ...[
            ProfileSelector(
              label: 'Sexo',
              value: _gender,
              items: opcionesSexo,
              onChanged: (val) {
                setState(() => _gender = val);
              },
            ),

            const SizedBox(height: 12),

            ProfileCenterField(
              controller: _ageCtrl,
              label: 'Tu edad',
              validator: emptyFieldValidator,
            ),

            const SizedBox(height: 12),

            ProfileCenterField(
              controller: _weightCtrl,
              label: widget.useMetric ? 'Tu peso (kg)' : 'Tu peso (lb)',
              validator: emptyFieldValidator,
            ),

            const SizedBox(height: 12),

            ProfileCenterField(
              controller: _heightCtrl,
              label: widget.useMetric ? 'Tu altura (cm)' : 'Tu altura (in)',
              validator: emptyFieldValidator,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  _step1Valid
                      ? () => setState(() => _showQuestions = true)
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: actualtheme.colorScheme.secondary,
                foregroundColor: actualtheme.colorScheme.primary,
              ),
              child: const Text('Siguiente'),
            ),
          ],

          // Step 2
          if (_showQuestions) ...[
            OptionStepper(
              label: 'Actividad física diaria',
              options: nivelesActividad,
              onChanged: (val) => setState(() => _activityLevel = val),
            ),

            const SizedBox(height: 12),

            OptionStepper(
              label: 'Objetivo principal',
              options: objetivos,
              onChanged: (val) => setState(() => _goal = val),
            ),

            const SizedBox(height: 12),

            OptionStepper(
              label: 'Superávit calórico diario',
              options: superavitOptions,
              onChanged: (val) => setState(() => _calorieSurplus = val),
            ),

            const SizedBox(height: 12),

            ProfileCenterField(
              controller: _bodyFatCtrl,
              label: '(Opcional) % grasa corporal',
              validator: (v) => null,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                _calculateMacros();
                if (_calories != null) _showResultsSheet();
              },
              icon: const Icon(Icons.restaurant_menu_rounded),
              label: const Text('Calcular Macros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: actualtheme.colorScheme.secondary,
                foregroundColor: actualtheme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _calculateMacros() {
    if (!_formKey.currentState!.validate()) return;

    final age = double.parse(_ageCtrl.text);
    final rawWeight = double.parse(_weightCtrl.text);
    final rawHeight = double.parse(_heightCtrl.text);
    final weightKg = widget.useMetric ? rawWeight : rawWeight * 0.453592;
    final heightCm = widget.useMetric ? rawHeight : rawHeight * 2.54;

    final bmr =
        (_gender == kGeneroHombre)
            ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
            : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    final activityFactors = {
      nivelesActividad[0]: 1.2,
      nivelesActividad[1]: 1.375,
      nivelesActividad[2]: 1.55,
      nivelesActividad[3]: 1.725,
      nivelesActividad[4]: 1.9,
    };
    double maintenance = bmr * (activityFactors[_activityLevel] ?? 1.2);

    final digits = _calorieSurplus?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
    final delta = int.tryParse(digits) ?? 0;
    if (_goal == objetivos[1]) {
      maintenance += delta;
    } else if (_goal == objetivos[2]) {
      maintenance -= delta;
    }

    _calories = maintenance;
    _minCarb = (maintenance * 0.45) / 4;
    _maxCarb = (maintenance * 0.65) / 4;
    _minProtein = (maintenance * 0.10) / 4;
    _maxProtein = (maintenance * 0.35) / 4;
    _minFat = (maintenance * 0.20) / 9;
    _maxFat = (maintenance * 0.35) / 9;

    setState(() {});

    // Avisamos para que cierre el popup
    if (widget.onCalculated != null) {
      widget.onCalculated!();
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);

    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    final userService = getIt<UsuarioService>();

    if (authUser == null) {
      showNeutralSnackBar(context, 'No estás autenticado');
      setState(() => _loadingProfile = false);
      return;
    }

    try {
      final usuario = await userService.fetchUsuarioByAuthId(authUser.id);
      if (usuario == null) {
        showErrorSnackBar(context, 'Usuario no encontrado');
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
      showErrorSnackBar(context, 'Error al cargar datos');
    } finally {
      setState(() => _loadingProfile = false);
    }
  }

  void _showResultsSheet() {
    final actualtheme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: actualtheme.colorScheme.primary,
      builder:
          (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6, // 60% de la pantalla
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Consumo diario recomendado:',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const Divider(thickness: 2),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DataTable(
                              columns: const [
                                DataColumn(label: Text('Macronutrientes')),
                                DataColumn(label: Text('Mínimo')),
                                DataColumn(label: Text('Máximo')),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    const DataCell(Text('Hidratos de carbono')),
                                    DataCell(
                                      Text('${_minCarb!.toStringAsFixed(0)} g'),
                                    ),
                                    DataCell(
                                      Text('${_maxCarb!.toStringAsFixed(0)} g'),
                                    ),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    const DataCell(Text('Proteínas')),
                                    DataCell(
                                      Text(
                                        '${_minProtein!.toStringAsFixed(0)} g',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '${_maxProtein!.toStringAsFixed(0)} g',
                                      ),
                                    ),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    const DataCell(Text('Grasas')),
                                    DataCell(
                                      Text('${_minFat!.toStringAsFixed(0)} g'),
                                    ),
                                    DataCell(
                                      Text('${_maxFat!.toStringAsFixed(0)} g'),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'Los mínimos y máximos son (g/día).',
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  static String? emptyFieldValidator(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null;
}
