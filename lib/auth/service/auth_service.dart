import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para registrar usuarios y validar emails con Supabase Auth
class AuthService {
  final SupabaseClient _supabase;

  /// Inyecta cliente Supabase o usa el singleton por defecto
  AuthService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  /// Comprueba si un email ya está registrado:
  /// - Llama a la función RPC 'user_exists' en Supabase
  /// - Interpreta la respuesta en distintos formatos (bool, num, Map, List)
  Future<bool> emailExists(String email) async {
    try {
      final raw = await _supabase.rpc(
        'user_exists',
        params: {'_email': email.trim()},
      );
      // Caso bool
      if (raw is bool) return raw;
      // Caso num
      if (raw is num) return raw > 0;
      // Caso Map
      if (raw is Map<String, dynamic>) {
        if (raw.containsKey('user_exists')) {
          final v = raw['user_exists'];
          if (v is bool) return v;
          if (v is num) return v > 0;
        }
        if (raw.containsKey('count') && raw['count'] is num) {
          return (raw['count'] as num) > 0;
        }
      }
      // Caso List
      if (raw is List && raw.isNotEmpty) {
        final first = raw.first;
        if (first is bool) return first;
        if (first is num) return first > 0;
        if (first is Map<String, dynamic>) {
          if (first.containsKey('user_exists')) {
            final v = first['user_exists'];
            if (v is bool) return v;
            if (v is num) return v > 0;
          }
          if (first.containsKey('count') && first['count'] is num) {
            return (first['count'] as num) > 0;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error en emailExists: $e');
      return false;
    }
  }

  /// Convierte mensajes de error API en mensajes amigables al usuario
  String mapError(String apiMsg) {
    switch (apiMsg) {
      case 'Invalid email address':
        return 'El formato del correo no es válido.';
      case 'User already registered':
      case 'email_exists':
        return 'Este correo ya está en uso.';
      case 'Password should be a string with minimum length of 6':
      case 'weak_password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'validation_failed':
        return 'Los datos introducidos no son válidos.';
      case 'conflict':
        return 'Parece que ya existe una operación en curso. Intenta de nuevo.';
      default:
        return apiMsg; // Devolver mensaje original si no hay mapeo
    }
  }

  /// Registra un usuario con email y contraseña
  /// - Lanza excepción de Supabase en caso de fallo
  Future<void> signUp({required String email, required String password}) async {
    await _supabase.auth.signUp(email: email, password: password);
  }
}
