import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

/// Notificador de receta diaria:
/// - Carga/crea receta al instanciar
/// - Resetea cuando cambia día o tramo
class DailyRecipeNotifier extends ChangeNotifier {
  // Al crear, inicia la lectura o creación de la receta
  DailyRecipeNotifier() {
    initDailyRecipe();
  }

  final SupabaseClient _supabase = Supabase.instance.client; // Cliente Supabase

  // Estado de la receta diaria
  String? _titulo;
  int? _calorias;
  int? _tiempoPreparacion;
  String? _descripcionBreve;
  String? _tramoHorario;
  DateTime? _fecha;
  bool _isLoading = false;
  String? _error;

  String? get titulo => _titulo;
  int? get calorias => _calorias;
  int? get tiempoPreparacion => _tiempoPreparacion;
  String? get descripcionBreve => _descripcionBreve;
  String? get tramoHorario => _tramoHorario;
  DateTime? get fecha => _fecha;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fecha de hoy formateada como 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  // Determina si es desayuno, comida o cena según hora actual
  String get _currentTramo {
    final h = DateTime.now().hour;
    if (h >= 6 && h <= 12) return 'desayuno';
    if (h >= 13 && h <= 19) return 'comida';
    return 'cena';
  }

  /// 0) Inicializa o resetea si cambió día/tramo
  Future<void> initDailyRecipe() async {
    try {
      await _fetchOrCreateRecipe();
      if (_fecha == null ||
          _fecha!.toIso8601String().split('T').first != _hoyKey ||
          _tramoHorario != _currentTramo) {
        await resetDailyRecipe();
      }
    } catch (e) {
      _error = 'Error al inicializar receta: $e';
    }
    notifyListeners();
  }

  /// 1) Lee registro existente o crea uno nuevo con datos de GPT
  Future<void> _fetchOrCreateRecipe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await _supabase
              .from('receta_diaria')
              .select(
                'titulo, calorias, tiempo_preparacion, descripcion_breve, fecha, tramo_horario',
              )
              .eq('user_id', user.id)
              .maybeSingle();

      if (data == null) {
        await _createRecipeRecord();
      } else {
        _titulo = data['titulo'] as String?;
        _calorias = (data['calorias'] as int?) ?? 0;
        _tiempoPreparacion = (data['tiempo_preparacion'] as int?) ?? 0;
        _descripcionBreve = data['descripcion_breve'] as String?;
        _fecha = DateTime.tryParse(data['fecha'] as String);
        _tramoHorario = data['tramo_horario'] as String?;
      }
    } catch (e) {
      _error = 'Error al leer receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2) Crea el registro usando JSON obtenido de ChatGPT
  Future<void> _createRecipeRecord() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawJson = await fetchDailyRecipeFromGPT(_currentTramo);
      final receta = jsonDecode(rawJson) as Map<String, dynamic>;
      final row =
          await _supabase
              .from('receta_diaria')
              .insert({
                'user_id': user.id,
                'fecha': _hoyKey,
                'tramo_horario': _currentTramo,
                'titulo': receta['titulo'],
                'calorias': receta['calorias'],
                'tiempo_preparacion': receta['tiempo_preparacion'],
                'descripcion_breve': receta['breve'],
              })
              .select()
              .maybeSingle();

      if (row != null) {
        _titulo = row['titulo'] as String?;
        _calorias = (row['calorias'] as int?) ?? 0;
        _tiempoPreparacion = (row['tiempo_preparacion'] as int?) ?? 0;
        _descripcionBreve = row['descripcion_breve'] as String?;
        _fecha = DateTime.tryParse(row['fecha'] as String);
        _tramoHorario = row['tramo_horario'] as String?;
      }
    } catch (e) {
      _error = 'Error al crear receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3) Fuerza nueva llamada a GPT y actualiza registro si cambió día/tramo
  Future<void> resetDailyRecipe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final rawJson = await fetchDailyRecipeFromGPT(_currentTramo);
      final receta = jsonDecode(rawJson) as Map<String, dynamic>;
      await _supabase
          .from('receta_diaria')
          .update({
            'fecha': _hoyKey,
            'tramo_horario': _currentTramo,
            'titulo': receta['titulo'],
            'calorias': receta['calorias'],
            'tiempo_preparacion': receta['tiempo_preparacion'],
            'descripcion_breve': receta['breve'],
          })
          .eq('user_id', user.id);

      await _fetchOrCreateRecipe();
    } catch (e) {
      _error = 'Error al resetear receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
