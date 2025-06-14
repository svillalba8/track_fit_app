import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/core/utils/snackbar_utils.dart';
import 'package:track_fit_app/notifiers/daily_challenge_notifier.dart';

/// Diálogo flotante para gestionar el flujo del reto diario:
/// - Comprueba o genera el reto de hoy
/// - Muestra errores o estado completado
/// - Permite marcar como hecho al usuario
class DailyChallengeDialog {
  static const String _kTituloRetoDiario = '🏅 Reto del día 🏅';

  /// Inicia todo el proceso de mostrar el diálogo
  static Future<void> show(BuildContext context) async {
    final challengeProv = context.read<DailyChallengeNotifier>();
    final actualTheme = Theme.of(context);

    // 1) Asegura que exista el reto de hoy (o lo crea)
    await challengeProv.ensureTodayChallengeExists();

    // 2) Si hubo error al obtener/crear, mostramos SnackBar y salimos
    if (challengeProv.retoError != null) {
      if (!context.mounted) return;
      showErrorSnackBar(context, challengeProv.retoError!);
      return;
    }

    // 3) Si no hay texto de reto, informamos y salimos
    final textoReto = challengeProv.retoTexto;
    if (textoReto == null || textoReto.isEmpty) {
      if (!context.mounted) return;
      showNeutralSnackBar(context, 'No se encontró reto para hoy.');
      return;
    }

    // 4) Si ya completó el reto, mostramos diálogo de felicitación
    if (challengeProv.retoCompletado) {
      if (!context.mounted) return;
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
                    color: actualTheme.colorScheme.secondary,
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

    if (!context.mounted) return;

    // 5) Si no está completado, mostramos el reto con botón "Hecho"
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
                color: actualTheme.colorScheme.secondary,
                onPressed: () => ctx.pop(),
              ),
            ],
          ),
          content: Text(textoReto, style: const TextStyle(fontSize: 16)),
          actions: [
            // Botón para indicar que ya está hecho
            ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: actualTheme.colorScheme.tertiary,
                foregroundColor: actualTheme.colorScheme.secondary,
              ),
              onPressed: () async {
                // a) Cerrar diálogo actual
                ctx.pop();

                // b) Confirmar realmente si el usuario completó el reto
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

                // c) Si confirma, marca el reto y avisa con SnackBar
                if (confirm == true) {
                  await challengeProv.markChallengeDone();
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
