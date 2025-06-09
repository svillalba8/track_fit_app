import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Envía [message] a ChatGPT y devuelve la respuesta generada.
Future<String> chatWithTrainer(String message, {String? userName}) async {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  /// Prompt de sistema para FitCoachGPT
  const String kFitCoachSystemPrompt = r'''
    Eres L.I.F.T, entrenador personal experto en fitness y nutrición.
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
      {
        'role': 'system',
        'content':
            kFitCoachSystemPrompt +
            (userName != null
                ? '\n7. Ten encuenta que el usuario se llama "$userName".'
                : ''),
      },
      if (userName != null)
        {'role': 'system', 'content': 'El nombre de usuario es $userName.'},
      {'role': 'user', 'content': message},
    ],
    // Opcional: controlar longitud y coste
    'max_tokens': 400,
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

/// Obtiene un reto diario (mini‐reto de ejercicio) usando un prompt específico.
Future<String> fetchDailyChallengeFromGPT() async {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Prompt de sistema específico para generar retos diarios:
  const String kDailyChallengeSystemPrompt = r'''
    Hoy tu tarea es COMBINAR todos estos requisitos:
    1. Generar **un único enunciado** que sea **breve** y **conciso**.
    2. El reto debe ser **fácil de realizar en casa** o en un espacio reducido, usando solo el propio peso corporal.
    3. Ofrecer **un ejemplo concreto** (p. ej. “Haz 20 sentadillas”, “Mantén plancha 3 minutos” o “5 minutos de saltos de tijera”).
    4. No agregues explicaciones adicionales;
    5. Devuelve solo el texto del reto, sin formato extra (sin numeración, sin subtítulos, sin viñetas).

    Ejemplos de salida deseada:
    - “Haz 20 sentadillas en 2 series.”
    - “Mantén una plancha estática durante 3 minutos.”
    - “Realiza 5 minutos de saltos de tijera.”

    Responde con un único enunciado corto y directo que cumpla todos los puntos.
  ''';

  // Usamos el mismo modelo que en chatWithTrainer (gpt-3.5-turbo), o cambia a gpt-4 si prefieres.
  const String model = 'gpt-3.5-turbo';
  final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');

  // Construimos el body con nuestro prompt de sistema y un contenido de usuario estático:
  final Map<String, dynamic> body = {
    'model': model,
    'messages': [
      {'role': 'system', 'content': kDailyChallengeSystemPrompt},
      {'role': 'user', 'content': 'Genera el reto de hoy.'},
    ],
    'max_tokens': 100, // Un reto breve no necesita muchos tokens
    'temperature': 0.7, // Ligera aleatoriedad
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
      // 1. Decodificamos la respuesta como UTF-8
      final raw = resp.bodyBytes;
      final utf8Body = utf8.decode(raw);
      // 2. Parseamos JSON
      final decoded = jsonDecode(utf8Body) as Map<String, dynamic>;
      // 3. Extraemos el texto generado
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

/// Obtiene una receta diaria (desayuno/comida/cena) usando ChatGPT
Future<String> fetchDailyRecipeFromGPT(String slot, {String? userName}) async {
  final String apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Prompt de sistema específico para recetas diarias:
  const String kDailyRecipeSystemPrompt = r'''
    Eres L.I.F.T., un nutricionista experto. 
    Para el tramo “desayuno” (o “comida”/“cena”), devuélveme **solo** un JSON así:

    {
      "titulo": "Nombre de la receta",
      "calorias": 350,
      "tiempo_preparacion": 15,
      "breve": "2 tostadas integrales con aguacate y huevo pochado."
    }

    Sin ningún texto extra y la descripción lo mas breve posible.
      ''';

  const String model = 'gpt-3.5-turbo';
  final Uri uri = Uri.parse('https://api.openai.com/v1/chat/completions');

  // Construimos el body al estilo de los otros métodos
  final Map<String, dynamic> body = {
    'model': model,
    'messages': [
      {
        'role': 'system',
        'content':
            kDailyRecipeSystemPrompt +
            (userName != null
                ? '\nNota: el usuario se llama "$userName".'
                : ''),
      },
      if (userName != null)
        {'role': 'system', 'content': 'El nombre de usuario es $userName.'},
      {'role': 'user', 'content': 'Quiero una receta para: $slot.'},
    ],
    'max_tokens': 400,
    'temperature': 0.7,
  };

  try {
    final resp = await http
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
      final raw = resp.bodyBytes;
      final utf8Body = utf8.decode(raw);
      final decoded = jsonDecode(utf8Body) as Map<String, dynamic>;
      final String reply =
          decoded['choices'][0]['message']['content'] as String;
      return reply.trim();
    } else {
      return 'Error ${resp.statusCode}: ${resp.body}';
    }
  } on TimeoutException {
    return 'Error: la petición a OpenAI tardó demasiado tiempo.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}
