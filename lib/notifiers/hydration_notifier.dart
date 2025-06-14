import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HydrationNotifier extends ChangeNotifier {
  // Tras creación, inicia carga del estado de hidratación
  HydrationNotifier() {
    initHydration();
  }

  // Constantes de meta de hidratación
  static const int _kCapacidadTotalMl = 8000; // Límite máximo diario
  static const int _kCantidadRecomendada = 4000; // Meta diaria

  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado de hidratación diaria
  int _mlBebidos = 0; // Mililitros consumidos hoy
  int _diasCompletados = 0; // Días en que se alcanzó la meta
  DateTime? _ultimoDia; // Fecha del último día completado
  DateTime? _fechaActualizacion; // Fecha de la última actualización
  bool _isHydrationLoading = false; // Indicador de carga
  String? _hydrationError; // Mensaje de error si ocurre

  int get mlBebidos => _mlBebidos;
  int get diasCompletados => _diasCompletados;
  DateTime? get ultimoDia => _ultimoDia;
  DateTime? get fechaActualizacion => _fechaActualizacion;
  bool get isHydrationLoading => _isHydrationLoading;
  String? get hydrationError => _hydrationError;

  /// Devuelve la fecha de hoy en 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  /// 1) Inicializa el registro: carga o crea datos y reinicia si es un día nuevo
  Future<void> initHydration() async {
    try {
      await _fetchOrCreateHydrationRecord();
      final hoy = DateTime.parse(_hoyKey);
      if (_fechaActualizacion == null || _fechaActualizacion!.isBefore(hoy)) {
        await resetHydration();
      }
    } catch (e) {
      _hydrationError = 'Error al inicializar hidratación: $e';
    }
    notifyListeners();
  }

  /// 2) Obtiene o crea el registro de hidratación para el usuario
  Future<void> _fetchOrCreateHydrationRecord() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _hydrationError = 'Usuario no autenticado';
      _isHydrationLoading = false;
      notifyListeners();
      return;
    }

    _isHydrationLoading = true;
    _hydrationError = null;
    notifyListeners();

    try {
      final data =
          await _supabase
              .from('hidratacion_usuario')
              .select(
                'ml_bebidos, dias_completados, ultimo_dia_completado, fecha_actualizacion',
              )
              .eq('user_id', user.id)
              .maybeSingle();

      if (data == null) {
        await _createHydrationRecord(user.id);
      } else {
        // Carga valores desde la BD
        _mlBebidos = (data['ml_bebidos'] as int?) ?? 0;
        _diasCompletados = (data['dias_completados'] as int?) ?? 0;
        _ultimoDia =
            (data['ultimo_dia_completado'] != null)
                ? DateTime.tryParse(data['ultimo_dia_completado'] as String)
                : null;
        _fechaActualizacion =
            (data['fecha_actualizacion'] != null)
                ? DateTime.tryParse(data['fecha_actualizacion'] as String)
                : null;
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

  /// 3) Inserta un nuevo registro con valores iniciales a 0
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
      } else {
        // Carga valores recién insertados
        _mlBebidos = (insertData['ml_bebidos'] as int?) ?? 0;
        _diasCompletados = (insertData['dias_completados'] as int?) ?? 0;
        _ultimoDia = null;
        _fechaActualizacion = null;
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

  /// 4) Añade ml al contador, actualiza en BD y marca día si alcanza la meta
  Future<void> addWater(BuildContext context, int cantidadMl) async {
    if (_mlBebidos >= _kCapacidadTotalMl) return;
    final messenger = ScaffoldMessenger.of(context);

    // Actualiza estado local inmediatamente
    _mlBebidos = (_mlBebidos + cantidadMl).clamp(0, _kCapacidadTotalMl);
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase
          .from('hidratacion_usuario')
          .update({'ml_bebidos': _mlBebidos, 'fecha_actualizacion': _hoyKey})
          .eq('user_id', user.id);
      _fechaActualizacion = DateTime.parse(_hoyKey);
    } catch (e) {
      _hydrationError = 'Error al actualizar hidratación: $e';
    }

    // Si alcanza la meta recomendada, incrementa días completados
    if (_mlBebidos == _kCantidadRecomendada) {
      _diasCompletados += 1;
      try {
        await _supabase
            .from('hidratacion_usuario')
            .update({
              'dias_completados': _diasCompletados,
              'ultimo_dia_completado': _hoyKey,
            })
            .eq('user_id', user.id);

        messenger.showSnackBar(
          const SnackBar(
            content: Text('¡Genial, has completado la hidratación diaria!'),
            duration: Duration(seconds: 4),
          ),
        );
      } catch (e) {
        _hydrationError = 'Error al actualizar días completados: $e';
      }
    }

    notifyListeners();
  }

  /// 5) Reinicia el conteo de hidratación para un nuevo día
  Future<void> resetHydration() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
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
          .eq('user_id', user.id);
      _mlBebidos = 0;
      _fechaActualizacion = null;
    } catch (e) {
      _hydrationError = 'Error al resetear hidratación: $e';
    } finally {
      _isHydrationLoading = false;
      notifyListeners();
    }
  }
}
