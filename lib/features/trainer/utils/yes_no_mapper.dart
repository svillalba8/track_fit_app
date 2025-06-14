import 'package:track_fit_app/models/message.dart';

/// Mapea respuestas 'yes'/'no' de la API a entidad de mensaje
class YesNoMapper {
  // Respuesta cruda ('yes' o 'no')
  final String answer;
  // Indica si la respuesta fue forzada por la app
  final bool forced;

  const YesNoMapper({required this.answer, required this.forced});

  /// Crea instancia desde JSON obtenido de la API
  factory YesNoMapper.fromJsonMap(Map<String, dynamic> json) => YesNoMapper(
    answer: json["answer"] as String,
    forced: json["forced"] as bool,
  );

  /// Convierte la instancia a JSON para enviar a la API si es necesario
  Map<String, dynamic> toJson() => {"answer": answer, "forced": forced};

  /// Transforma la respuesta en un objeto Message para el chat:
  /// - 'yes' → 'Si'
  /// - cualquier otro valor → 'No'
  Message toMessageEntity() =>
      Message(text: answer == 'yes' ? 'Si' : 'No', fromWho: FromWho.his);
}
