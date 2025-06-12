import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HydrationNotifier extends ChangeNotifier {
  HydrationNotifier() {
    // Comprobamos el estado de hidratación
    initHydration();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  // --------------------- Estado para hidratación diaria ---------------------
  int _mlBebidos = 0;
  int _diasCompletados = 0;
  DateTime? _ultimoDia;
  DateTime? _fechaActualizacion;
  bool _isHydrationLoading = false;
  String? _hydrationError;

  int get mlBebidos => _mlBebidos;
  int get diasCompletados => _diasCompletados;
  DateTime? get ultimoDia => _ultimoDia;
  DateTime? get fechaActualizacion => _fechaActualizacion;
  bool get isHydrationLoading => _isHydrationLoading;
  String? get hydrationError => _hydrationError;

  /// Devuelve la fecha de hoy en formato 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  // Constantes de hidratación:
  static const int _kCapacidadTotalMl = 8000;
  static const int _kCantidadRecomendada = 4000;

  // ----------------------- Lógica para “hidratación” -----------------------

  Future<void> initHydration() async {
    try {
      await _fetchOrCreateHydrationRecord();
      // Tras esto, _mlBebidos, _diasCompletados, _ultimoDia y _fechaActualizacion ya estarán cargados
      final hoy = DateTime.parse(_hoyKey);
      if (_fechaActualizacion == null || _fechaActualizacion!.isBefore(hoy)) {
        await resetHydration();
      }
    } catch (e) {
      _hydrationError = 'Error al inicializar hidratación: $e';
    }

    notifyListeners();
  }

  /// 1) Comprueba si ya hay un registro de hidratación para hoy.
  ///    Si existe, carga los datos; si no, llama a _createHydrationRecord().
  Future<void> _fetchOrCreateHydrationRecord() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      _hydrationError = 'Usuario no autenticado';
      _isHydrationLoading = false;
      notifyListeners();
      return;
    }

    _isHydrationLoading = true;
    _hydrationError = null;
    notifyListeners();

    try {
      // maybeSingle() devuelve Map<String,dynamic>? o null si no hay fila
      final data =
          await _supabase
              .from('hidratacion_usuario')
              .select(
                'ml_bebidos, dias_completados, ultimo_dia_completado, fecha_actualizacion',
              )
              .eq('user_id', authUser.id)
              .maybeSingle();

      if (data == null) {
        // No hay fila → la creamos con valores por defecto
        await _createHydrationRecord(authUser.id);
      } else {
        // data es Map<String, dynamic>
        _mlBebidos = (data['ml_bebidos'] as int?) ?? 0;
        _diasCompletados = (data['dias_completados'] as int?) ?? 0;
        final fechaStr = data['ultimo_dia_completado'] as String?;
        _ultimoDia = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
        final fechaActStr = data['fecha_actualizacion'] as String?;
        _fechaActualizacion =
            fechaActStr != null ? DateTime.tryParse(fechaActStr) : null;
      }
    } on PostgrestException catch (e) {
      _hydrationError = 'Error Supabase al leer hidratación: ${e.message}';
      _mlBebidos = 0;
      _diasCompletados = 0;
      _ultimoDia = null;
    } catch (e) {
      _hydrationError = 'Excepción al leer hidratación: $e';
      _mlBebidos = 0;
      _diasCompletados = 0;
      _ultimoDia = null;
    } finally {
      _isHydrationLoading = false;
      notifyListeners();
    }
  }

  /// 2) Crea la fila inicial de hidratación para el usuario con valores a 0.
  Future<void> _createHydrationRecord(String userId) async {
    try {
      final insertData =
          await _supabase
              .from('hidratacion_usuario')
              .insert({
                'user_id': userId,
                'ml_bebidos': 0,
                'dias_completados': 0,
                'ultimo_dia_completado': null,
                'fecha_actualizacion': null,
              })
              .select(
                'ml_bebidos, dias_completados, ultimo_dia_completado, fecha_actualizacion',
              )
              .maybeSingle();

      if (insertData == null) {
        _hydrationError = 'No se pudo insertar registro de hidratación';
        _mlBebidos = 0;
        _diasCompletados = 0;
        _ultimoDia = null;
      } else {
        _mlBebidos = (insertData['ml_bebidos'] as int?) ?? 0;
        _diasCompletados = (insertData['dias_completados'] as int?) ?? 0;
        final fechaStr = insertData['ultimo_dia_completado'] as String?;
        _ultimoDia = fechaStr != null ? DateTime.tryParse(fechaStr) : null;
        final fechaActStr = insertData['fecha_actualizacion'] as String?;
        _fechaActualizacion =
            fechaActStr != null ? DateTime.tryParse(fechaActStr) : null;
      }
    } on PostgrestException catch (e) {
      _hydrationError = 'Error al crear registro de hidratación: ${e.message}';
      _mlBebidos = 0;
      _diasCompletados = 0;
      _ultimoDia = null;
      _fechaActualizacion = null;
    } catch (e) {
      _hydrationError = 'Excepción al crear hidratación: $e';
      _mlBebidos = 0;
      _diasCompletados = 0;
      _ultimoDia = null;
      _fechaActualizacion = null;
    }
  }

  /// 3) Agrega cierta cantidad de agua (en ml) localmente y luego actualiza en la base.
  Future<void> addWater(BuildContext context, int cantidadMl) async {
    // Si ya bebimos la capacidad total, no hace nada
    if (_mlBebidos >= _kCapacidadTotalMl) return;

    final messenger = ScaffoldMessenger.of(context);

    // Actualiza el estado local inmediatamente
    final nuevoMl = (_mlBebidos + cantidadMl).clamp(0, _kCapacidadTotalMl);
    _mlBebidos = nuevoMl;
    notifyListeners();

    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return;

    try {
      await _supabase
          .from('hidratacion_usuario')
          .update({'ml_bebidos': _mlBebidos, 'fecha_actualizacion': _hoyKey})
          .eq('user_id', authUser.id);

      _fechaActualizacion = DateTime.parse(_hoyKey);
    } on PostgrestException catch (e) {
      _hydrationError = 'Error al actualizar ml_bebidos: ${e.message}';
    } catch (e) {
      _hydrationError = 'Excepción al actualizar hidratación: $e';
    }

    if (_mlBebidos == _kCantidadRecomendada) {
      _diasCompletados += 1;

      try {
        await _supabase
            .from('hidratacion_usuario')
            .update({
              'dias_completados': _diasCompletados,
              'ultimo_dia_completado': _hoyKey,
            })
            .eq('user_id', authUser.id);

        messenger.showSnackBar(
          SnackBar(
            content: Text('¡Genial, has completado la hidratación diaria!'),
            duration: Duration(seconds: 4),
          ),
        );
      } on PostgrestException catch (e) {
        _hydrationError = 'Error al actualizar ml_bebidos: ${e.message}';
      } catch (e) {
        _hydrationError = 'Excepción al actualizar hidratación: $e';
      }
    }

    notifyListeners();
  }

  /// 4) Reinicia el conteo de hidratación a 0 (al iniciar nuevo día)
  Future<void> resetHydration() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      _hydrationError = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _isHydrationLoading = true;
    _hydrationError = null;
    notifyListeners();

    try {
      await _supabase
          .from('hidratacion_usuario')
          .update({'ml_bebidos': 0, 'fecha_actualizacion': null})
          .eq('user_id', authUser.id);
      _mlBebidos = 0;
      _fechaActualizacion = null;
      _hydrationError = null;
    } on PostgrestException catch (e) {
      _hydrationError = 'Error al resetear hidratación: ${e.message}';
    } catch (e) {
      _hydrationError = 'Excepción al resetear hidratación: $e';
    } finally {
      _isHydrationLoading = false;
      notifyListeners();
    }
  }
}
