import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:track_fit_app/data/di.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/services/usuario_service.dart';

class ChatNotifier extends ChangeNotifier {
  // Controlador de scroll para el listado de mensajes
  final ScrollController chatScrollController = ScrollController();
  // Servicio de usuario inyectado
  final UsuarioService _userService = getIt<UsuarioService>();
  // Cliente Supabase para acceder a auth y base de datos
  final SupabaseClient _supabase = Supabase.instance.client;

  String? _userName; // Nombre del usuario autenticado
  List<Message> messageList = []; // Lista de mensajes en el chat

  ChatNotifier() {
    // Carga el nombre de usuario y envía mensaje de bienvenida al iniciar
    loadUserName();
  }

  /// Inicializa el mensaje de bienvenida (usa _userName si está disponible)
  Future<void> initWelcomeMessage() async {
    if (_userName == null) await loadUserName();
    final greeting =
        (_userName != null)
            ? '¡Hola $_userName! Soy tu entrenador personal. ¿En qué puedo ayudarte hoy?'
            : '¡Hola! Soy tu entrenador personal. ¿En qué puedo ayudarte hoy?';

    // Reemplaza lista con solo el saludo inicial
    messageList = [Message(text: greeting, fromWho: FromWho.his)];
    notifyListeners();
  }

  /// Envía un mensaje del usuario y espera la respuesta del entrenador
  Future<void> sendMessage(String text) async {
    // Añade mensaje del usuario
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    // Solicita la respuesta
    await hisReplay(newMessage.text);
    notifyListeners();
    moveScrollToBottom();
  }

  /// Procesa la respuesta: muestra "Pensando...", llama a la API y actualiza lista
  Future<void> hisReplay(String question) async {
    final typingMessage = Message(text: "Pensando...", fromWho: FromWho.his);
    messageList.add(typingMessage);
    notifyListeners();
    moveScrollToBottom();

    try {
      // Llama al servicio de ChatGPT con la pregunta y nombre de usuario
      String answer = await chatWithTrainer(question, userName: _userName);
      // Reemplaza el mensaje de "Pensando..." con la respuesta real
      messageList
        ..remove(typingMessage)
        ..add(Message(text: answer, fromWho: FromWho.his));
    } catch (e) {
      // En caso de error, muestra mensaje de fallo
      messageList
        ..remove(typingMessage)
        ..add(
          Message(text: "Error al obtener respuesta", fromWho: FromWho.his),
        );
    }
    notifyListeners();
    moveScrollToBottom();
  }

  /// Desplaza el scroll hasta el final para mostrar el último mensaje
  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  /// Carga el nombre del usuario autenticado y lanza el saludo inicial
  Future<void> loadUserName() async {
    final authUser = _supabase.auth.currentUser;
    if (authUser == null) return;
    final usuario = await _userService.fetchUsuarioByAuthId(authUser.id);
    if (usuario != null) {
      _userName = usuario.nombre;
      await initWelcomeMessage();
    }
  }
}
