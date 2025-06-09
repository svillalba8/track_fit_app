import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/models/progreso_model.dart';
import 'package:track_fit_app/services/progreso_service.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

class EditGoalPage extends StatefulWidget {
  final ProgresoModel? progreso;

  const EditGoalPage({super.key, this.progreso});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  final _formKey = GlobalKey<FormState>();
  final _objetivoController = TextEditingController();
  final _fechaObjetivoController = TextEditingController();

  late final TextEditingController _pesoInicialController;
  late final TextEditingController _pesoActualController;
  late final TextEditingController _fechaInicioController;

  bool _isEditing = false;
  bool _isSaving = false;

  late final ProgresoModel progreso;

  @override
  void initState() {
    super.initState();
    progreso = widget.progreso!;
    _objetivoController.text = progreso.objetivoPeso.toString();
    _fechaObjetivoController.text =
        progreso.fechaObjetivo != null
            ? DateFormat('yyyy-MM-dd').format(progreso.fechaObjetivo!)
            : '';

    _pesoInicialController = TextEditingController(
      text: progreso.pesoInicial?.toStringAsFixed(1) ?? '-',
    );
    _pesoActualController = TextEditingController(
      text: progreso.pesoActual.toStringAsFixed(1),
    );
    _fechaInicioController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(progreso.fechaComienzo),
    );
  }

  @override
  void dispose() {
    _objetivoController.dispose();
    _fechaObjetivoController.dispose();
    _pesoInicialController.dispose();
    _pesoActualController.dispose();
    _fechaInicioController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    final pesoActual = double.tryParse(_pesoActualController.text.trim());
    final objetivo = double.tryParse(_objetivoController.text.trim());
    final fechaObjetivo =
        _fechaObjetivoController.text.isNotEmpty
            ? DateTime.tryParse(_fechaObjetivoController.text.trim())
            : null;

    if (pesoActual == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Introduce un peso actual válido');
      return;
    }

    if (objetivo == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Introduce un objetivo válido');
      return;
    }

    final actualizado = progreso.copyWith(
      pesoActual: pesoActual,
      objetivoPeso: objetivo,
      fechaObjetivo: fechaObjetivo,
    );

    setState(() => _isSaving = true);

    try {
      final progresoService = GetIt.I<ProgresoService>();

      final actualizadoEnBBDD = await progresoService.updateProgreso(
        actualizado,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);
      showSuccessSnackBar(context, 'Objetivo actualizado');
      context.pop(actualizadoEnBBDD);
    } on PostgrestException catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      debugPrint('Error Supabase: ${e.message}');
      showErrorSnackBar(context, 'Error al guardar cambios: ${e.message}');
    } catch (e, stacktrace) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      debugPrint('Error inesperado al guardar progreso: $e');
      debugPrintStack(stackTrace: stacktrace);
      showErrorSnackBar(context, 'Error al guardar cambios');
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: progreso.fechaObjetivo ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      _fechaObjetivoController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _confirmarCancelarEdicion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Cancelar edición?'),
            content: const Text('Se descartarán los cambios no guardados.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _isEditing = false;
        _objetivoController.text = progreso.objetivoPeso.toString();
        _fechaObjetivoController.text =
            progreso.fechaObjetivo != null
                ? DateFormat('yyyy-MM-dd').format(progreso.fechaObjetivo!)
                : '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Objetivo de progreso'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancelar edición' : 'Editar',
            onPressed: () {
              if (_isEditing) {
                _confirmarCancelarEdicion();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ProfileField(
                label: 'Peso inicial (kg)',
                controller: _pesoInicialController,
                readOnly: true,
              ),

              const SizedBox(height: 12),

              ProfileField(
                label: 'Peso actual (kg)',
                controller: _pesoActualController,
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isEditing) return null;
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Introduce un valor válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              ProfileField(
                controller: _objetivoController,
                label: 'Objetivo (kg)',
                readOnly: !_isEditing,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isEditing) return null;
                  final double? parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Introduce un valor válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _isEditing ? _seleccionarFecha : null,
                child: AbsorbPointer(
                  absorbing: !_isEditing,
                  child: ProfileField(
                    controller: _fechaObjetivoController,
                    label: 'Fecha objetivo (opcional)',
                    readOnly: !_isEditing,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ProfileField(
                label: 'Fecha de inicio',
                controller: _fechaInicioController,
                readOnly: true,
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _isEditing
                        ? CustomButton(
                          key: const ValueKey('boton_guardar'),
                          text: _isSaving ? 'Guardando...' : 'Guardar cambios',
                          actualTheme: theme,
                          onPressed: _isSaving ? null : () => _guardarCambios(),
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
