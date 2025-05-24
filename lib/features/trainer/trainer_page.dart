import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/themes/theme_extensions.dart';
import 'package:track_fit_app/features/trainer/widgets/his_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/message_field_box.dart';
import 'package:track_fit_app/features/trainer/widgets/my_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/quick_calculator_actions.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/notifiers/chat_notifier.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

class TrainerPage extends StatelessWidget {
  const TrainerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    return Scaffold(
      // AppBar personalizado con altura extra y degradado
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: CustomDivider(),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  actualTheme.colorScheme.primaryFixed,
                  actualTheme.colorScheme.onTertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            children: [
              // Avatar del entrenador
              CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage(kavatarEntrenadorPersonal1),
              ),
              SizedBox(width: 12),
              // Nombre y estado debajo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'L.I.F.T', // Live Intelligent Fitness Trainer
                    style: TextStyle(
                      fontSize: 20,
                      color: actualTheme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '¡Listo para ayudarte!',
                    style: TextStyle(
                      fontSize: 14,
                      color: actualTheme.colorScheme.secondary.withAlpha(140),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Botones de acceso directo
            QuickCalculatorsActions(actualTheme: actualTheme),
            CustomIconButton(
              icon: Icon(Icons.settings, size: 28),
              actualTheme: actualTheme,
              onPressed: () {
                /* abrir configuración */
              },
            ),
          ],
        ),
      ),
      body: _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatNotifier>();
    final actualTheme = Theme.of(context);
    final backgroundExtension = actualTheme.extension<ChatBackground>();
    final backgroundAsset =
        backgroundExtension?.assetPath ??
        'assets/backgrounds/default_chat_bg.png';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
      ),
    );
  }
}
