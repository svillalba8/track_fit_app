import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/auth/widgets/profile_field.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/features/trainer/widgets/date_objective_field.dart';
import 'package:track_fit_app/models/progreso_model.dart';
import 'package:track_fit_app/services/progreso_service.dart';
import 'package:track_fit_app/services/usuario_service.dart';
import 'package:track_fit_app/widgets/custom_button.dart';

// Página para crear o editar un objetivo de progreso de peso
class EditGoalPage extends StatefulWidget {
  // Modelo de progreso opcional, si es null se crea uno nuevo
  final ProgresoModel? progreso;

  const EditGoalPage({super.key, this.progreso});

  @override
  State<EditGoalPage> createState() => _EditGoalPageState();
}

class _EditGoalPageState extends State<EditGoalPage> {
  // Clave del formulario para validaciones
  final _formKey = GlobalKey<FormState>();
  // Controladores de texto para los campos de entrada
  final _objetivoController = TextEditingController();
  final _fechaObjetivoController = TextEditingController();
  final TextEditingController _pesoInicialController = TextEditingController();
  final TextEditingController _pesoActualController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();

  // Flags para controlar edición, guardado y carga
  bool _isEditing = false;
  bool _isSaving = false;
  bool _loading = true;

  // Progreso actual (nuevo o existente)
  late ProgresoModel progreso;

  @override
  void initState() {
    super.initState();
    if (widget.progreso == null) {
      // Si no hay progreso, iniciar creación de uno nuevo
      _isEditing = true;
      _inicializarNuevoProgreso();
    } else {
      // Si existe progreso, cargar datos para edición
      progreso = widget.progreso!;
      _setupControllersFromProgreso();
      _loading = false;
    }
  }

  // Inicializa un nuevo ProgresoModel con peso inicial del usuario actual
  Future<void> _inicializarNuevoProgreso() async {
    final hoy = DateTime.now();
    final supabase = GetIt.I<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    double pesoActual = 0;
    if (authUser != null) {
      final usuarioService = GetIt.I<UsuarioService>();
      final usuario = await usuarioService.fetchUsuarioByAuthId(authUser.id);
      pesoActual = usuario?.peso ?? 0;
    }
    // Crear modelo con datos por defecto
    progreso = ProgresoModel(
      id: 0,
      fechaComienzo: hoy,
      objetivoPeso: 0,
      fechaObjetivo: null,
      pesoInicial: pesoActual,
    );
    _setupControllersFromProgreso();
    setState(() => _loading = false);
  }

  // Carga valores del modelo en los controladores de texto
  Future<void> _setupControllersFromProgreso() async {
    final supabase = GetIt.I<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    double pesoActual = 0;
    if (authUser != null) {
      final usuarioService = GetIt.I<UsuarioService>();
      final usuario = await usuarioService.fetchUsuarioByAuthId(authUser.id);
      pesoActual = usuario?.peso ?? 0;
    }
    _objetivoController.text =
        (progreso.objetivoPeso != null && progreso.objetivoPeso! > 0)
            ? progreso.objetivoPeso!.toString()
            : '';
    _fechaObjetivoController.text =
        progreso.fechaObjetivo != null
            ? formatSpanishDate(progreso.fechaObjetivo!)
            : '';
    _pesoInicialController.text = progreso.pesoInicial.toStringAsFixed(1);
    _pesoActualController.text = pesoActual.toStringAsFixed(1);
    _fechaInicioController.text = formatSpanishDate(progreso.fechaComienzo);
  }

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _objetivoController.dispose();
    _fechaObjetivoController.dispose();
    _pesoInicialController.dispose();
    _pesoActualController.dispose();
    _fechaInicioController.dispose();
    super.dispose();
  }

  // Guarda o actualiza el objetivo en el servicio correspondiente
  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return; // Validar formulario

    final pesoActual = double.tryParse(_pesoActualController.text.trim());
    final objetivo = double.tryParse(_objetivoController.text.trim());
    final fechaObjetivo = progreso.fechaObjetivo;

    // Comprobar valores válidos
    if (pesoActual == null || objetivo == null || fechaObjetivo == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Revisa los valores introducidos');
      return;
    }

    final progresoACrear = progreso.copyWith(
      objetivoPeso: objetivo,
      fechaObjetivo: fechaObjetivo,
    );

    setState(() => _isSaving = true);

    try {
      final servicio = GetIt.I<ProgresoService>();
      if (progreso.id == 0) {
        // Crear nuevo objetivo
        final creado = await servicio.createProgreso(
          objetivoPeso: objetivo,
          pesoInicial: progresoACrear.pesoInicial,
          fechaObjetivo: progresoACrear.fechaObjetivo,
        );
        await servicio.updatePesoUsuario(pesoActual);
        if (!mounted) return;
        showSuccessSnackBar(context, 'Objetivo creado');
        context.pop(creado);
      } else {
        // Actualizar objetivo existente
        final actualizado = await servicio.updateProgreso(progresoACrear);
        await servicio.updatePesoUsuario(pesoActual);
        if (!mounted) return;
        showSuccessSnackBar(context, 'Objetivo actualizado');
        context.pop(actualizado);
      }
    } catch (e) {
      debugPrint('Error al guardar: $e');
      showErrorSnackBar(context, 'Error interno al guardar cambios');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Muestra un selector de fecha y actualiza el modelo y controlador
  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: progreso.fechaObjetivo ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        progreso = progreso.copyWith(fechaObjetivo: picked);
        _fechaObjetivoController.text = formatSpanishDate(picked);
      });
    }
  }

  // Confirma al usuario si desea cancelar la edición y descartar cambios
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
        _setupControllersFromProgreso();
      });
    }
  }

  // Formatea una fecha a estilo español: "día de mes de año"
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

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);

    if (_loading) {
      // Mostrar indicador de carga mientras se inicializa
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Estructura principal de la página con AppBar y formulario
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
              // Campo: peso inicial (siempre de solo lectura)
              ProfileField(
                label: 'Peso inicial (kg)',
                controller: _pesoInicialController,
                readOnly: true,
              ),

              const SizedBox(height: 12),

              // Campo: peso actual (editable solo en modo edición)
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

              // Campo: objetivo (kg)
              ProfileField(
                controller: _objetivoController,
                label: 'Objetivo (kg)',
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

              // Campo personalizado para seleccionar fecha objetivo
              FechaObjetivoField(
                controller: _fechaObjetivoController,
                isEditable: _isEditing,
                onTapIcon: _seleccionarFecha,
              ),

              const SizedBox(height: 12),

              // Campo: fecha de inicio (solo lectura)
              ProfileField(
                label: 'Fecha de inicio',
                controller: _fechaInicioController,
                readOnly: true,
              ),

              const SizedBox(height: 24),

              // Botón de guardar con animación y estado de guardado
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _isEditing
                        ? CustomButton(
                          key: const ValueKey('boton_guardar'),
                          text: _isSaving ? 'Guardando...' : 'Guardar cambios',
                          actualTheme: actualTheme,
                          onPressed: _isSaving ? null : _guardarCambios,
                        )
                        : const SizedBox.shrink(),
              ),
              // Opción para cancelar objetivo existente
              TextButton.icon(
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: Text('Cancelar objetivo'),
                          content: Text(
                            '¿Estás seguro de que quieres cancelar tu objetivo actual?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text('Sí'),
                            ),
                          ],
                        ),
                  );

                  if (confirmar != true) return;

                  try {
                    final servicio = GetIt.I<ProgresoService>();
                    final actualizado = await servicio.cancelarObjetivo(
                      progreso.id,
                    );
                    if (!context.mounted) return;
                    showSuccessSnackBar(context, 'Objetivo cancelado');
                    context.pop(actualizado);
                  } catch (e) {
                    debugPrint('Error al cancelar objetivo: $e');
                    if (!context.mounted) return;
                    showErrorSnackBar(
                      context,
                      'No se pudo cancelar el objetivo',
                    );
                  }
                },
                icon: Icon(Icons.cancel_outlined),
                label: Text('Cancelar objetivo'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
