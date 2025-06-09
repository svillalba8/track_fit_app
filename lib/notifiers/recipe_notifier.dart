import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

class RecipeNotifier extends ChangeNotifier {
  RecipeNotifier() {
    initTodayRecipe();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  // — Estado espejo de las columnas de receta_diaria —
  String? _recipeId;
  String? _tramoHorario;
  String? _titulo;
  int? _calorias;
  int? _tiempoPreparacion;
  String? _descripcionBreve;

  bool _isLoading = false;
  String? _error;

  // — Getters para la UI —
  String? get recipeId => _recipeId;
  String? get tramoHorario => _tramoHorario;
  String? get titulo => _titulo;
  int? get calorias => _calorias;
  int? get tiempoPreparacion => _tiempoPreparacion;
  String? get descripcionBreve => _descripcionBreve;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fecha de hoy en 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  /// Devuelve 'desayuno'|'comida'|'cena'
  String _currentMealSlot() {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 12) return 'desayuno';
    if (h >= 12 && h < 19) return 'comida';
    return 'cena';
  }

  /// 1) Inicializa fetch/insert
  Future<void> initTodayRecipe() async {
    try {
      await _fetchTodayRecipe();
      if (_recipeId == null && _error == null) {
        await _createTodayRecipe();
      }
    } catch (e) {
      _error = 'Error al inicializar receta: $e';
      notifyListeners();
    }
  }

  /// 2) Lee de Supabase la fila si existe para hoy+tramo
  Future<void> _fetchTodayRecipe() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    try {
      final slot = _currentMealSlot();
      final data =
          await _supabase
              .from('receta_diaria')
              .select('''
            id,
            tramo_horario,
            titulo,
            calorias,
            tiempo_preparacion,
            descripcion_breve
          ''')
              .eq('user_id', user.id)
              .eq('fecha', _hoyKey)
              .eq('tramo_horario', slot)
              .maybeSingle();

      if (data != null) {
        _recipeId = data['id'] as String;
        _tramoHorario = data['tramo_horario'] as String;
        _titulo = data['titulo'] as String;
        _calorias = data['calorias'] as int;
        _tiempoPreparacion = data['tiempo_preparacion'] as int;
        _descripcionBreve = data['descripcion_breve'] as String;
        _error = null;
      }
    } on PostgrestException catch (e) {
      _error = 'Supabase read error: ${e.message}';
    } catch (e) {
      _error = 'Excepción al leer receta: $e';
    }

    notifyListeners();
  }

  /// 3) Si no había, solicita a ChatGPT el JSON meta y guarda
  Future<void> _createTodayRecipe() async {
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
      final slot = _currentMealSlot();
      final rawJson = await fetchDailyRecipeFromGPT(slot);

      // Parsear el JSON (prompt A)
      final Map<String, dynamic> meta = jsonDecode(rawJson);
      final titulo = meta['titulo'] as String;
      final calorias = (meta['calorias'] as num).toInt();
      final tiempo = (meta['tiempo_preparacion'] as num).toInt();
      final breve = meta['breve'] as String;

      // Insertar en BD
      final inserted =
          await _supabase
              .from('receta_diaria')
              .insert({
                'user_id': user.id,
                'fecha': _hoyKey,
                'tramo_horario': slot,
                'titulo': titulo,
                'calorias': calorias,
                'tiempo_preparacion': tiempo,
                'descripcion_breve': breve,
              })
              .select('''
            id,
            tramo_horario,
            titulo,
            calorias,
            tiempo_preparacion,
            descripcion_breve
          ''')
              .maybeSingle();

      if (inserted == null) {
        _error = 'No se pudo guardar la receta';
      } else {
        _recipeId = inserted['id'] as String;
        _tramoHorario = inserted['tramo_horario'] as String;
        _titulo = inserted['titulo'] as String;
        _calorias = inserted['calorias'] as int;
        _tiempoPreparacion = inserted['tiempo_preparacion'] as int;
        _descripcionBreve = inserted['descripcion_breve'] as String;
      }
    } on FormatException catch (e) {
      _error = 'JSON inválido: $e';
    } on PostgrestException catch (e) {
      _error = 'Supabase insert error: ${e.message}';
    } catch (e) {
      _error = 'Excepción al generar receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
