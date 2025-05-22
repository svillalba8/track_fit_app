import 'package:flutter/material.dart';
import 'package:track_fit_app/features/trainer/service/get_chat_gpt_answer.dart';
import 'package:track_fit_app/models/message.dart';

class ChatNotifier extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController();

  List<Message> messageList = [
    Message(
      text: 'Hola soy CHAT-GPT, en que puedo ayudarte?',
      fromWho: FromWho.his,
    ),
  ];

  Future<void> sendMessage(String text) async {
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    await hisReplay(newMessage.text);

    notifyListeners(); // Función similiar a SetState() {}
    moveScrollToBottom();
  }

  Future<void> hisReplay(String question) async {
    final typingMessage = Message(text: "Pensando...", fromWho: FromWho.his);
    messageList.add(typingMessage);
    notifyListeners();
    moveScrollToBottom();

    try {
      String answer = await chatWithTrainer(question);

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
}
