import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Envía [message] a ChatGPT y devuelve la respuesta generada.
Future<String> chatWithTrainer(String message) async {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  /// Prompt de sistema para FitCoachGPT
  const String kFitCoachSystemPrompt = r'''
    Eres FitCoachGPT, entrenador personal experto en fitness y nutrición.
    1. Personaliza planes según nivel (principiante/intermedio/avanzado), objetivos y limitaciones.
    2. Ofrece rutinas completas (calentamiento, parte principal, enfriamiento).
    3. Da consejos de nutrición pre y post entreno.
    4. Explica técnica y seguridad en ejercicios.
    5. Sugiere progresión semanal.
    6. Motiva y, si falta info (edad, peso, experiencia), pregunta antes de dar el plan.
    Responde claro, estructurado y adaptado al usuario.
    ''';

  // GPT-4 cuesta 20 veces más en el prompt y 30 veces más en la respuesta que gpt-3.5-turbo
  const String model = 'gpt-3.5-turbo'; // o "gpt-4" si fuese necesario
  final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');

  // Construimos el cuerpo JSON según la spec de Chat Completions
  final Map<String, dynamic> body = {
    'model': model,
    'messages': [
      {'role': 'system', 'content': kFitCoachSystemPrompt},
      {'role': 'user', 'content': message},
    ],
    // Opcional: controlar longitud y coste
    'max_tokens': 200, // Si falta info cambiar a 200–250
    'temperature': 0.7,
  };

  try {
    final http.Response resp = await http
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 60));

    if (resp.statusCode == 200) {
      // 1. Toma los bytes crudos de la respuesta
      final raw = resp.bodyBytes;
      // 2. Decódelos como UTF-8 para evitar caracteres extraños
      final utf8Body = utf8.decode(raw);
      // 3. Parsealo a JSON
      final decoded = jsonDecode(utf8Body) as Map<String, dynamic>;
      // 4. Extrae tu texto
      final String reply =
          decoded['choices'][0]['message']['content'] as String;
      return reply.trim();
    } else {
      return 'Error ${resp.statusCode}: ${resp.body}';
    }
  } on TimeoutException {
    return 'Error: la petición tardó demasiado tiempo.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}
