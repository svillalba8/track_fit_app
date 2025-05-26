import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/services/usuario_service.dart';

class ChatNotifier extends ChangeNotifier {
  ChatNotifier() {
    // Arrancamos aquí directamente la carga de nombre y el mensaje de bienvenida
    loadUserName();
  }

  final ScrollController chatScrollController = ScrollController();
  final UsuarioService _userService = getIt<UsuarioService>();

  String? _userName;

  List<Message> messageList = [];

  Future<void> initWelcomeMessage() async {
    // 1) Aseguramos que conseguimos el nombre:
    if (_userName == null) await loadUserName();

    // 2) Construimos el saludo personalizado:
    final greeting =
        (_userName != null)
            ? '¡Hola $_userName! Soy tu entrenador personal. ¿En qué puedo ayudarte hoy?'
            : '¡Hola! Soy tu entrenador personal. ¿En qué puedo ayudarte hoy?';

    // 3) Finalmente lo añadimos a la lista:
    messageList = [Message(text: greeting, fromWho: FromWho.his)];
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    await hisReplay(newMessage.text);

    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> hisReplay(String question) async {
    final typingMessage = Message(text: "Pensando...", fromWho: FromWho.his);
    messageList.add(typingMessage);
    notifyListeners();
    moveScrollToBottom();

    try {
      String answer = await chatWithTrainer(question, userName: _userName);

      messageList.remove(typingMessage);
      messageList.add(Message(text: answer, fromWho: FromWho.his));
    } catch (e) {
      messageList.remove(typingMessage);
      messageList.add(
        Message(text: "Error al obtener respuesta", fromWho: FromWho.his),
      );
    }
    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 100));

    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Carga el perfil y obtiene el nombre
  Future<void> loadUserName() async {
    final supabase = getIt<SupabaseClient>();
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;
    final usuario = await _userService.fetchUsuarioByAuthId(authUser.id);
    if (usuario != null) {
      _userName = usuario.nombre;
      await initWelcomeMessage();
    }
  }
}
