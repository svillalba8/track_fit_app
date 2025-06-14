
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// Inicializa Supabase con las credenciales cargadas desde el archivo .env
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',  // Obtiene la URL desde .env
        anonKey: dotenv.env['SUPABASE_KEY'] ?? '',// Obtiene la key desde .env
      );
      // Mensaje en consola si la inicialización fue exitosa
      debugPrint("Supabase initialized successfully");
    } catch (e) {
      // Atrapa y muestra cualquier error de inicialización
      debugPrint("Error initializing Supabase: $e");
    }
  }
}