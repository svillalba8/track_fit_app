/// Define quién envía el mensaje: el usuario o el entrenador
enum FromWho {
  me, // Mensajes del usuario
  his, // Mensajes del entrenador ("él")
}

/// Modelo simple para representar un mensaje en el chat
class Message {
  // Texto del mensaje
  final String text;
  // Emisor del mensaje (usuario o entrenador)
  final FromWho fromWho;

  Message({
    required this.text, // Contenido del mensaje
    required this.fromWho, // Quién lo envía
  });
}
