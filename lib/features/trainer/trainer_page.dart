import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/themes/theme_extensions.dart';
import 'package:track_fit_app/features/trainer/service/daily_challenge_dialog.dart';
import 'package:track_fit_app/features/trainer/widgets/his_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/message_field_box.dart';
import 'package:track_fit_app/features/trainer/widgets/my_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/quick_calculator_actions.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/notifiers/chat_notifier.dart';
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

/// Página principal del entrenador:
/// - Muestra AppBar con avatar y accesos rápidos
/// - Botón de reto diario que abre un diálogo
/// - Cuerpo con lista de mensajes y campo de entrada
class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  @override
  Widget build(BuildContext context) {
    // Lee si el reto diario está completado para cambiar el icono
    final retoCompletado =
        context.watch<DailyChallengeNotifier>().retoCompletado;
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar con altura aumentada y degradado de colores
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: AppBar(
          automaticallyImplyLeading: false,
          // Divider personalizado en la parte inferior
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: CustomDivider(),
          ),
          // Fondo degradado
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryFixed,
                  theme.colorScheme.onTertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Avatar y nombre del entrenador
          title: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: const AssetImage(kAvatarEntrenadorPersonal),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'L.I.F.T', // Nombre de la “IA entrenador”
                    style: TextStyle(
                      fontSize: 20,
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '¡Listo para ayudarte!', // Subtítulo de estado
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.secondary.withAlpha(140),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Acciones rápidas (calculadoras)
            QuickCalculatorsActions(actualTheme: theme),
            // Icono de reto diario (cambia si está cumplido) y abre diálogo
            CustomIconButton(
              icon:
                  retoCompletado
                      ? Image.asset(
                        'assets/icons/objetivo_diario_cumplido.png',
                        width: 24,
                        height: 24,
                        color: theme.colorScheme.secondary,
                      )
                      : Image.asset(
                        'assets/icons/objetivo_diario.png',
                        width: 24,
                        height: 24,
                        color: theme.colorScheme.secondary,
                      ),
              actualTheme: theme,
              onPressed: () {
                DailyChallengeDialog.show(context);
              },
            ),
          ],
        ),
      ),
      // Cuerpo con chat
      body: _ChatView(),
    );
  }
}

/// Vista del chat:
/// - Fondo según la extensión de tema
/// - ListView de mensajes (burbujas propias y ajenas)
/// - Campo de entrada para enviar mensajes
class _ChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatNotifier>();
    final theme = Theme.of(context);
    // Obtiene ruta de fondo desde la extensión de tema
    final bgAsset =
        theme.extension<ChatBackground>()?.assetPath ??
        'assets/backgrounds/default_chat_bg.png';

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bgAsset), // Imagen de fondo
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              // Lista de mensajes
              Expanded(
                child: ListView.builder(
                  controller: chatProv.chatScrollController,
                  itemCount: chatProv.messageList.length,
                  itemBuilder: (ctx, i) {
                    final msg = chatProv.messageList[i];
                    // Selecciona burbuja según emisor
                    return msg.fromWho == FromWho.his
                        ? HisMessageBubble(message: msg)
                        : MyMessageBubble(message: msg);
                  },
                ),
              ),
              // Caja de texto y botón para enviar mensaje
              MessageFieldBox(onValue: chatProv.sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}
