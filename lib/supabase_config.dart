
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    try {
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL'] ?? '',  // Obtiene la URL desde .env
        anonKey: dotenv.env['SUPABASE_KEY'] ?? '',// Obtiene la key desde .env
      );
      debugPrint("Supabase initialized successfully");
    } catch (e) {
      debugPrint("Error initializing Supabase: $e");
    }
  }
}