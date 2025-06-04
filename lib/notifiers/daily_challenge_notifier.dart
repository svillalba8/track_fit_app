import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

class DailyChallengeNotifier extends ChangeNotifier {
  DailyChallengeNotifier() {
    // Comprobamos el estado del reto diario
    initDailyChallenge();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  // ----------------------- Estado para el reto diario -----------------------
  String? _retoId;
  String? _retoTexto;
  bool _retoCompletado = false;
  bool _isRetoLoading = false;
  String? _retoError;

  String? get retoId => _retoId;
  String? get retoTexto => _retoTexto;
  bool get retoCompletado => _retoCompletado;
  bool get isRetoLoading => _isRetoLoading;
  String? get retoError => _retoError;

  /// Devuelve la fecha de hoy en formato 'yyyy-MM-dd' usando toIso8601String()
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  // ------------------------- Lógica para “reto diario” -------------------------
  Future<void> initDailyChallenge() async {
    try {
      await ensureTodayChallengeExists();
      // Tras esto, _retoId, _retoTexto y _retoCompletado ya estarán con los valores correctos.
    } catch (e) {
      // Opcional: si quieres capturar errores de arranque
      _retoError = 'Error al inicializar reto diario: $e';
    }
    // Notifico para que la UI actualice el icono desde el primer build.
    notifyListeners();
  }

  /// 1) Comprueba si ya hay un reto de hoy en Supabase.
  ///    Si existe, carga id, texto y completado; si no, deja _retoId = null.
  Future<void> _fetchTodayChallenge() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      _retoError = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    try {
      // .maybeSingle() devuelve Map<String,dynamic>? o null si no hay fila
      final data =
          await _supabase
              .from('reto_diario')
              .select('id, reto_texto, completado')
              .eq('user_id', authUser.id)
              .eq('fecha', _hoyKey)
              .maybeSingle();

      if (data == null) {
        // No existe reto para hoy
        _retoId = null;
        _retoTexto = null;
        _retoCompletado = false;
        _retoError = null;
      } else {
        // data es Map<String, dynamic>
        _retoId = data['id'] as String;
        _retoTexto = data['reto_texto'] as String;
        _retoCompletado = data['completado'] as bool;
        _retoError = null;
      }
    } on PostgrestException catch (e) {
      // Error de Supabase
      _retoError = 'Error Supabase al leer reto: ${e.message}';
      _retoId = null;
      _retoTexto = null;
      _retoCompletado = false;
    } catch (e) {
      _retoError = 'Excepción al leer reto: $e';
      _retoId = null;
      _retoTexto = null;
      _retoCompletado = false;
    }

    notifyListeners();
  }

  /// 2) Si no hay reto hoy, lo pide a GPT e inserta en Supabase.
  Future<void> _createTodayChallenge() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) {
      _retoError = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _isRetoLoading = true;
    _retoError = null;
    notifyListeners();

    try {
      // 2.1) Pedimos a GPT el reto del día
      final textoGenerado = await fetchDailyChallengeFromGPT();

      // 2.2) Insertamos en Supabase
      final insertData =
          await _supabase
              .from('reto_diario')
              .insert({
                'user_id': authUser.id,
                'fecha': _hoyKey,
                'reto_texto': textoGenerado,
              })
              .select('id, reto_texto, completado')
              .maybeSingle(); // Devuelve Map<String,dynamic>? con la fila insertada

      if (insertData == null) {
        _retoError = 'No se pudo insertar el reto';
        _retoId = null;
        _retoTexto = null;
        _retoCompletado = false;
      } else {
        _retoId = insertData['id'] as String;
        _retoTexto = insertData['reto_texto'] as String;
        _retoCompletado = insertData['completado'] as bool; // false
        _retoError = null;
      }
    } on PostgrestException catch (e) {
      _retoError = 'Error al insertar reto: ${e.message}';
      _retoId = null;
      _retoTexto = null;
      _retoCompletado = false;
    } catch (e) {
      _retoError = 'Excepción al generar reto: $e';
      _retoId = null;
      _retoTexto = null;
      _retoCompletado = false;
    } finally {
      _isRetoLoading = false;
      notifyListeners();
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
    _retoError = null;
    notifyListeners();

    try {
      await _supabase
          .from('reto_diario')
          .update({'completado': true})
          .eq('id', _retoId!);

      _retoCompletado = true;
    } on PostgrestException catch (e) {
      _retoError = 'Error al marcar completado: ${e.message}';
    } catch (e) {
      _retoError = 'Excepción al marcar completado: $e';
    } finally {
      _isRetoLoading = false;
      notifyListeners();
    }
  }

  /// 4) Método público que asegura que exista un reto hoy:
  ///    - Llama a _fetchTodayChallenge; si no hay reto y no hay error, crea uno.
  Future<void> ensureTodayChallengeExists() async {
    await _fetchTodayChallenge();
    if (_retoId == null && _retoError == null) {
      await _createTodayChallenge();
    }
  }
}
