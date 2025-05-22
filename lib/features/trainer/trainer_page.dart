import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/features/trainer/widgets/his_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/message_field_box.dart';
import 'package:track_fit_app/features/trainer/widgets/my_message_bubble.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/notifiers/chat_notifier.dart';

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://www.shutterstock.com/image-vector/minsk-belarus-03272023-openai-chatgpt-600nw-2281899103.jpg',
            ),
          ),
        ),
        title: Text('Chat-GPT'),
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatNotifier>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: chatProvider.chatScrollController,
                itemCount: chatProvider.messageList.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messageList[index];

                  return (message.fromWho == FromWho.his)
                      ? HisMessageBubble(message: message)
                      : MyMessageBubble(message: message);
                },
              ),
            ),
            MessageFieldBox(
              // OPCION A
              // onValue: (value) => chatProvider.sendMessage(value),
              // OPCION B
              onValue: chatProvider.sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
