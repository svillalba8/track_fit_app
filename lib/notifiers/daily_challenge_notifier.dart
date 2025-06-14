import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

/// Notificador para el reto diario:
/// - Inicializa al construir (diferido para evitar setState en build)
/// - Gestiona estado de carga, texto, completado y errores
class DailyChallengeNotifier extends ChangeNotifier {
  DailyChallengeNotifier() {
    // Arranca la inicialización tras la construcción
    Future.microtask(initDailyChallenge);
  }

  final SupabaseClient _supabase = Supabase.instance.client; // Cliente Supabase

  // Estado interno del reto diario
  String? _retoId; // ID del reto actual
  String? _retoTexto; // Texto descriptivo del reto
  bool _retoCompletado = false; // Si el reto ya está completado
  bool _isRetoLoading = false; // Indicador de carga
  String? _retoError; // Mensaje de error (si lo hay)
  DateTime? _ultimaFecha; // Fecha del último reto cargado

  String? get retoId => _retoId;
  String? get retoTexto => _retoTexto;
  bool get retoCompletado => _retoCompletado;
  bool get isRetoLoading => _isRetoLoading;
  String? get retoError => _retoError;
  DateTime? get ultimaFecha => _ultimaFecha;

  /// Clave de hoy en formato 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  /// Inicializa el reto diario:
  /// - Activa loading
  /// - Asegura que exista el reto de hoy o crea uno nuevo
  /// - Captura errores y desactiva loading
  Future<void> initDailyChallenge() async {
    _isRetoLoading = true;
    notifyListeners();

    try {
      await ensureTodayChallengeExists();
    } catch (e) {
      _retoError = 'Error al inicializar reto diario: $e';
    } finally {
      _isRetoLoading = false;
      notifyListeners();
    }
  }

  /// 1) Obtiene el reto más reciente de la base (sin filtrar por fecha)
  Future<Map<String, dynamic>?> _fetchLastChallenge() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return await _supabase
        .from('reto_diario')
        .select('id, reto_texto, completado, fecha')
        .eq('user_id', user.id)
        .order('fecha', ascending: false)
        .limit(1)
        .maybeSingle();
  }

  /// 2) Comprueba si el reto de hoy ya existe:
  ///    • Si existe (fecha ≥ hoy), reutiliza datos
  ///    • Si no, pide uno nuevo a GPT y lo guarda (upsert)
  Future<void> ensureTodayChallengeExists() async {
    final hoy = DateTime.parse(_hoyKey);
    final last = await _fetchLastChallenge();

    if (last != null) {
      final fechaUltimo = DateTime.tryParse(last['fecha'] as String);
      _ultimaFecha = fechaUltimo;
      if (fechaUltimo != null && !fechaUltimo.isBefore(hoy)) {
        // Reutiliza reto ya creado hoy
        _retoId = last['id'] as String;
        _retoTexto = last['reto_texto'] as String;
        _retoCompletado = last['completado'] as bool;
        return;
      }
    }

    // Genera texto nuevo con GPT y guarda/actualiza en la tabla
    final textoGenerado = await fetchDailyChallengeFromGPT();
    final user = _supabase.auth.currentUser!;
    final data =
        await _supabase
            .from('reto_diario')
            .upsert({
              'user_id': user.id,
              'fecha': _hoyKey,
              'reto_texto': textoGenerado,
              'completado': false,
            }, onConflict: 'user_id')
            .select('id, reto_texto, completado, fecha')
            .maybeSingle();

    if (data == null) {
      _retoError = 'No se pudo guardar el reto';
    } else {
      _retoId = data['id'] as String;
      _retoTexto = data['reto_texto'] as String;
      _retoCompletado = data['completado'] as bool;
      _ultimaFecha = DateTime.tryParse(data['fecha'] as String);
    }
  }

  /// 3) Marca el reto actual como completado:
  ///    • Actualiza la columna 'completado' a true
  ///    • Maneja loading, errores y notifica cambios
  Future<void> markChallengeDone() async {
    if (_retoId == null) {
      _retoError = 'No hay reto de hoy para marcar.';
      notifyListeners();
      return;
    }

    _isRetoLoading = true;
    _retoError = null;
    notifyListeners();

    try {
      await _supabase
          .from('reto_diario')
          .update({'completado': true})
          .eq('id', _retoId!);
      _retoCompletado = true;
    } catch (e) {
      _retoError = 'Error al marcar completado: $e';
    } finally {
      _isRetoLoading = false;
      notifyListeners();
    }
  }
}
