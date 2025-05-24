import 'package:track_fit_app/models/message.dart';

class YesNoMapper {
  final String answer;
  final bool forced;

  YesNoMapper({required this.answer, required this.forced});

  factory YesNoMapper.fromJsonMap(Map<String, dynamic> json) =>
      YesNoMapper(answer: json["answer"], forced: json["forced"]);

  Map<String, dynamic> toJson() => {"answer": answer, "forced": forced};

  // Funcion similar a el toString()
  Message toMessageEntity() =>
      Message(text: answer == 'yes' ? 'Si' : 'No', fromWho: FromWho.his);
}
