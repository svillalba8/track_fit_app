import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';

/// Clase estática que encapsula todo el flujo de diálogos del reto diario.
class DailyChallengeDialog {
  static const String _kTituloRetoDiario = '🏅 Reto del día 🏅';

  static Future<void> show(BuildContext context) async {
    final chatProvider = context.read<DailyChallengeNotifier>();
    final theme = Theme.of(context);

    // 1) Disparamos la lógica para comprobar/crear el reto
    await chatProvider.ensureTodayChallengeExists();

    // 2) Si hubo error en fetch/creación, mostramos SnackBar y salimos
    if (chatProvider.retoError != null) {
      if (!context.mounted) return;
      showErrorSnackBar(context, chatProvider.retoError!);
      return;
    }

    // Antes de usar context en asíncrono, comprobamos que siga montado:
    if (!context.mounted) return;

    // 3) Si no hay texto de reto, mostramos snackbar neutro y salimos
    final textoReto = chatProvider.retoTexto;
    if (textoReto == null || textoReto.isEmpty) {
      showNeutralSnackBar(context, 'No se encontró reto para hoy.');
      return;
    }

    // 4) Si ya está completado, mostramos diálogo informativo
    if (chatProvider.retoCompletado) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(_kTituloRetoDiario),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.close_rounded),
                    color: theme.colorScheme.secondary,
                    onPressed: () => ctx.pop(),
                  ),
                ],
              ),
              content: const Text(
                'Ya completaste el reto de hoy 🎉🎉',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
      );
      return;
    }

    // 5) Si aún no está completado, mostramos diálogo con "Cancelar" / "Hecho"
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(_kTituloRetoDiario),
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.close_rounded),
                color: theme.colorScheme.secondary,
                onPressed: () => ctx.pop(),
              ),
            ],
          ),
          content: Text(textoReto, style: const TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: theme.colorScheme.secondary,
              ),
              onPressed: () async {
                // 5.1) Cerramos este diálogo
                ctx.pop();

                // 5.2) Mostramos confirmación "¿Ya has terminado?"
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
                              backgroundColor: theme.colorScheme.tertiary,
                              foregroundColor: theme.colorScheme.secondary,
                            ),
                            onPressed: () => confirmCtx.pop(false),
                            child: const Text('Aún no'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: theme.colorScheme.tertiary,
                              foregroundColor: theme.colorScheme.secondary,
                            ),
                            onPressed: () => confirmCtx.pop(true),
                            child: const Text('Sí, he terminado'),
                          ),
                        ],
                      ),
                );

                // 5.3) Si confirma, marcamos como completado y mostramos snackbar
                if (confirm == true) {
                  await chatProvider.markChallengeDone();
                  if (!context.mounted) return;
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
}
