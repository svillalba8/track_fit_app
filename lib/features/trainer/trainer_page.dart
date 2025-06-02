import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/constants.dart';
import 'package:track_fit_app/core/themes/theme_extensions.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/features/trainer/widgets/his_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/message_field_box.dart';
import 'package:track_fit_app/features/trainer/widgets/my_message_bubble.dart';
import 'package:track_fit_app/features/trainer/widgets/quick_calculator_actions.dart';
import 'package:track_fit_app/models/message.dart';
import 'package:track_fit_app/notifiers/chat_notifier.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  /// Método que dispara la lógica de “reto diario” y muestra el diálogo correspondiente
  Future<void> showDailyChallenge() async {
    final chatProvider = context.read<ChatNotifier>();
    final actualTheme = Theme.of(context);
    const String kTituloRetoDiario = '🏅 Reto del día 🏅';

    // 1) Disparamos la lógica para comprobar/crear el reto
    await chatProvider.ensureTodayChallengeExists();

    // Aquí comprobamos que el State siga montado antes de usar `context`
    if (!mounted) return;

    // 2) Si hubo error en fetch o creación, mostramos SnackBar y salimos
    if (chatProvider.retoError != null) {
      showErrorSnackBar(context, chatProvider.retoError!);
      return;
    }

    // 3) A estas alturas, chatProvider.retoTexto ya tiene el texto del reto
    final textoReto = chatProvider.retoTexto;
    if (textoReto == null || textoReto.isEmpty) {
      showNeutralSnackBar(context, 'No se encontró reto para hoy.');
      return;
    }

    // 4) Si el reto ya está completado, mostramos un diálogo “informativo”
    if (chatProvider.retoCompletado) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(kTituloRetoDiario),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.close_rounded),
                    color: actualTheme.colorScheme.secondary,
                    onPressed: () {
                      ctx.pop();
                    },
                  ),
                ],
              ),
              content: Text(
                'Ya completaste el reto de hoy 🎉🎉',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
      );
      return;
    }

    // 5) Si aún no está completado, mostramos el diálogo con “Cancelar” / “Hecho”
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(kTituloRetoDiario),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.close_rounded),
                color: actualTheme.colorScheme.secondary,
                onPressed: () {
                  ctx.pop();
                },
              ),
            ],
          ),
          content: Text(textoReto, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: actualTheme.colorScheme.tertiary,
                foregroundColor: actualTheme.colorScheme.secondary,
              ),
              onPressed: () async {
                // 1) Cerramos el diálogo principal
                ctx.pop();

                // 2) Mostramos un segundo diálogo de confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (confirmCtx) => AlertDialog(
                        title: const Text('¿Ya has terminado el reto?'),
                        content: const Text(
                          '¿Ya has terminado? No nos engañes...',
                          style: TextStyle(fontSize: 15),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: actualTheme.colorScheme.tertiary,
                              foregroundColor:
                                  actualTheme.colorScheme.secondary,
                            ),
                            onPressed: () => confirmCtx.pop(false),
                            child: const Text('Aún no'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: actualTheme.colorScheme.tertiary,
                              foregroundColor:
                                  actualTheme.colorScheme.secondary,
                            ),
                            onPressed: () => confirmCtx.pop(true),
                            child: const Text('Sí, he terminado'),
                          ),
                        ],
                      ),
                );

                // 3) Si el usuario confirma, marcamos completado
                if (confirm == true) {
                  await chatProvider.markChallengeDone();
                  if (!mounted) return;
                  showNeutralSnackBar(context, '¡Reto completado! 🎉');
                }
              },
              child: const Text('Hecho'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final retoCompletado = context.watch<ChatNotifier>().retoCompletado;
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
                backgroundImage: AssetImage(kAvatarEntrenadorPersonal),
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
              icon:
                  retoCompletado
                      ? Image.asset(
                        'assets/icons/objetivo_diario_cumplido.png',
                        width: 24,
                        height: 24,
                        color: actualTheme.colorScheme.secondary,
                      )
                      : Image.asset(
                        'assets/icons/objetivo_diario.png',
                        width: 24,
                        height: 24,
                        color: actualTheme.colorScheme.secondary,
                      ),
              actualTheme: actualTheme,
              onPressed: () {
                showDailyChallenge();
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
