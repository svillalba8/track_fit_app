import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';

class DailyRecipeNotifier extends ChangeNotifier {
  DailyRecipeNotifier() {
    initDailyRecipe();
  }

  final SupabaseClient _supabase = Supabase.instance.client;

  // Estado de la receta diaria
  String? _titulo;
  int? _calorias;
  int? _tiempoPreparacion;
  String? _descripcionBreve;
  String? _tramoHorario;
  DateTime? _fecha;
  bool _isLoading = false;
  String? _error;

  // Getters públicos
  String? get titulo => _titulo;
  int? get calorias => _calorias;
  int? get tiempoPreparacion => _tiempoPreparacion;
  String? get descripcionBreve => _descripcionBreve;
  String? get tramoHorario => _tramoHorario;
  DateTime? get fecha => _fecha;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Formatea la fecha de hoy como 'yyyy-MM-dd'
  String get _hoyKey => DateTime.now().toIso8601String().split('T').first;

  // Lógica para decidir en qué tramo estamos
  String get _currentTramo {
    final h = DateTime.now().hour;
    if (h >= 6 && h < 12) return 'desayuno';
    if (h >= 12 && h < 16) return 'comida';
    return 'cena';
  }

  /// 0) Inicialización: leer o crear la receta diaria y, si cambió
  ///    el día o el tramo horario, forzar un “reset” (una actualización).
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

  /// 1) Intenta leer la fila; si no existe, la crea con datos de la API.
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
        // No había fila → creamos ya con datos de ChatGPT
        await _createRecipeRecord();
      } else {
        // Asignamos localmente
        _titulo = data['titulo'] as String?;
        _calorias = (data['calorias'] as int?) ?? 0;
        _tiempoPreparacion = (data['tiempo_preparacion'] as int?) ?? 0;
        _descripcionBreve = data['descripcion_breve'] as String?;
        _fecha = DateTime.tryParse(data['fecha'] as String);
        _tramoHorario = data['tramo_horario'] as String?;
      }
    } on PostgrestException catch (e) {
      _error = 'Error Supabase al leer receta: ${e.message}';
    } catch (e) {
      _error = 'Excepción al leer receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 2) Crea la fila **con los datos devueltos por ChatGPT**.
  Future<void> _createRecipeRecord() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 2.1) Llamada a tu API para obtener JSON con título, calorías, tiempo y breve
      final rawJson = await fetchDailyRecipeFromGPT(_currentTramo);
      final receta = jsonDecode(rawJson) as Map<String, dynamic>;

      // 2.2) Insertamos esa receta
      final insertData = {
        'user_id': user.id,
        'fecha': _hoyKey,
        'tramo_horario': _currentTramo,
        'titulo': receta['titulo'],
        'calorias': receta['calorias'],
        'tiempo_preparacion': receta['tiempo_preparacion'],
        'descripcion_breve': receta['breve'],
      };

      final row =
          await _supabase
              .from('receta_diaria')
              .insert(insertData)
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
    } on FormatException catch (e) {
      _error = 'Error al parsear JSON de receta: $e';
    } on PostgrestException catch (e) {
      _error = 'Error Supabase al crear receta: ${e.message}';
    } catch (e) {
      _error = 'Excepción al crear receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 3) Cuando cambia día/tramo, pedimos de nuevo a la API y actualizamos.
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
      // 3.1) Nueva llamada a ChatGPT
      final rawJson = await fetchDailyRecipeFromGPT(_currentTramo);
      final receta = jsonDecode(rawJson) as Map<String, dynamic>;

      // 3.2) Actualizamos la fila existente
      final updateData = {
        'fecha': _hoyKey,
        'tramo_horario': _currentTramo,
        'titulo': receta['titulo'],
        'calorias': receta['calorias'],
        'tiempo_preparacion': receta['tiempo_preparacion'],
        'descripcion_breve': receta['breve'],
      };

      await _supabase
          .from('receta_diaria')
          .update(updateData)
          .eq('user_id', user.id);

      // 3.3) Volvemos a leer y asignar localmente
      await _fetchOrCreateRecipe();
    } on FormatException catch (e) {
      _error = 'Error al parsear JSON de receta: $e';
    } on PostgrestException catch (e) {
      _error = 'Error Supabase al actualizar receta: ${e.message}';
    } catch (e) {
      _error = 'Excepción al resetear receta: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
