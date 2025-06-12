import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

class DailyChallengeNotifier extends ChangeNotifier {
  DailyChallengeNotifier() {
    // Comprobamos el estado del reto diario
    // ← CAMBIO: diferir init para evitar setState en build
    Future.microtask(initDailyChallenge);
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  // ----------------------- Estado para el reto diario -----------------------
  String? _retoId;
  String? _retoTexto;
  bool _retoCompletado = false;
  bool _isRetoLoading = false;
  String? _retoError;
  DateTime? _ultimaFecha; // ← AÑADIDO: para guardar fecha del último reto

  String? get retoId => _retoId;
  String? get retoTexto => _retoTexto;
  bool get retoCompletado => _retoCompletado;
  bool get isRetoLoading => _isRetoLoading;
  String? get retoError => _retoError;
  DateTime? get ultimaFecha => _ultimaFecha; // ← AÑADIDO: getter opcional

  /// Devuelve la fecha de hoy en formato 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  Future<void> initDailyChallenge() async {
    _isRetoLoading = true;
    notifyListeners(); // ← CAMBIO: iniciar loading aquí

    try {
      // ← CAMBIO: usamos nuevo flujo que compara fechas
      await ensureTodayChallengeExists();
    } catch (e) {
      _retoError = 'Error al inicializar reto diario: $e';
    } finally {
      _isRetoLoading = false;
      notifyListeners();
    }
  }

  /// 1) Trae siempre el último reto (sin filtrar por fecha)
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

  /// 2) Compara última fecha y genera o reutiliza reto
  Future<void> ensureTodayChallengeExists() async {
    final hoy = DateTime.parse(_hoyKey);

    // 2.1) Traemos el reto más reciente
    final last = await _fetchLastChallenge();

    if (last != null) {
      final fechaStr = last['fecha'] as String;
      final fechaUltimo = DateTime.tryParse(fechaStr);
      _ultimaFecha = fechaUltimo; // ← GUARDAR fecha

      if (fechaUltimo != null && !fechaUltimo.isBefore(hoy)) {
        // Si ya hay reto de hoy, lo reutilizamos
        _retoId = last['id'] as String;
        _retoTexto = last['reto_texto'] as String;
        _retoCompletado = last['completado'] as bool;
        return;
      }
    }

    // 2.2) Si no hay reto de hoy, pedimos a GPT y guardamos uno nuevo
    final textoGenerado = await fetchDailyChallengeFromGPT();
    final user = _supabase.auth.currentUser!;

    final data =
        await _supabase
            .from('reto_diario')
            .upsert(
              {
                'user_id': user.id,
                'fecha': _hoyKey,
                'reto_texto': textoGenerado,
                'completado': false,
              },
              onConflict: 'user_id',
            ) // ← USAR upsert con onConflict como String
            .select('id, reto_texto, completado, fecha')
            .maybeSingle();

    if (data == null) {
      _retoError = 'No se pudo guardar el reto';
    } else {
      _retoId = data['id'] as String;
      _retoTexto = data['reto_texto'] as String;
      _retoCompletado = data['completado'] as bool;
      final nuevaFecha = data['fecha'] as String;
      _ultimaFecha = DateTime.tryParse(nuevaFecha); // ← GUARDAR fecha
    }
  }

  /// 3) Marca el reto de hoy como completado (UPDATE).
  Future<void> markChallengeDone() async {
    if (_retoId == null) {
      _retoError = 'No hay reto de hoy para marcar.';
      notifyListeners();
      return;
    }

    _isRetoLoading = true;
    notifyListeners();
    _retoError = null;

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
