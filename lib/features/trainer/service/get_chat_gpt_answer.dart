import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Envía un mensaje a ChatGPT y devuelve la respuesta del entrenador.
Future<String> chatWithTrainer(String message, {String? userName}) async {
  final apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Prompt de sistema que define a L.I.F.T., experto en fitness
  const systemPrompt = r'''
    Eres L.I.F.T, entrenador personal experto en fitness y nutrición.
    1. Personaliza planes según nivel, objetivos y limitaciones.
    2. Ofrece rutinas completas.
    3. Da consejos de nutrición pre y post entreno.
    4. Explica técnica y seguridad.
    5. Sugiere progresión semanal.
    6. Si falta info, pregunta antes de dar el plan.
  ''';

  final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
  final body = {
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'system',
        'content':
            systemPrompt + (userName != null ? '\nUsuario: $userName.' : ''),
      },
      if (userName != null)
        {'role': 'system', 'content': 'Nombre de usuario: $userName.'},
      {'role': 'user', 'content': message},
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
      // Decodifica la respuesta y extrae el contenido
      final decoded =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      return (decoded['choices'][0]['message']['content'] as String).trim();
    } else {
      return 'Error ${resp.statusCode}: ${resp.body}';
    }
  } on TimeoutException {
    return 'Error: la petición tardó demasiado tiempo.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}

/// Solicita a ChatGPT un reto diario breve y devuelve solo el texto del reto.
Future<String> fetchDailyChallengeFromGPT() async {
  final apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Prompt específico para generar un único enunciado de reto
  const systemPrompt = r'''
    Genera un único enunciado breve y concreto:
    - Fácil de realizar en casa, solo con peso corporal.
    - Ejemplo: “Haz 20 sentadillas en 2 series.”
    Devuelve solo el texto sin formato extra.
  ''';

  final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
  final body = {
    'model': 'gpt-3.5-turbo',
    'messages': [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': 'Genera el reto de hoy.'},
    ],
    'max_tokens': 100,
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
      final decoded =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      return (decoded['choices'][0]['message']['content'] as String).trim();
    } else {
      return 'Error ${resp.statusCode}: ${resp.body}';
    }
  } on TimeoutException {
    return 'Error: la petición tardó demasiado tiempo.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}

/// Solicita a ChatGPT una receta diaria en JSON para desayuno/comida/cena.
Future<String> fetchDailyRecipeFromGPT(String slot, {String? userName}) async {
  final apiKey = dotenv.env['OPENAI_API_KEY']!;

  // Prompt que instruye a devolver solo un JSON con título, calorías, tiempo y breve descripción.
  const systemPrompt = r'''
    Eres nutricionista experto.
    Para el tramo “desayuno”/“comida”/“cena”, retorna SOLO este JSON:
    {
      "titulo": "...",
      "calorias": 350,
      "tiempo_preparacion": 15,
      "breve": "Descripción breve."
    }
    Sin texto adicional.
  ''';

  final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
  final body = {
    'model': 'gpt-3.5-turbo',
    'messages': [
      {
        'role': 'system',
        'content':
            systemPrompt + (userName != null ? '\nUsuario: $userName.' : ''),
      },
      if (userName != null)
        {'role': 'system', 'content': 'Nombre de usuario: $userName.'},
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
      final decoded =
          jsonDecode(utf8.decode(resp.bodyBytes)) as Map<String, dynamic>;
      return (decoded['choices'][0]['message']['content'] as String).trim();
    } else {
      return 'Error ${resp.statusCode}: ${resp.body}';
    }
  } on TimeoutException {
    return 'Error: la petición a OpenAI tardó demasiado tiempo.';
  } catch (e) {
    return 'Error inesperado: $e';
  }
}
