import 'package:flutter/material.dart';

/// Muestra un SnackBar de error con fondo rojo durante 2 segundos.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color.fromARGB(255, 240, 70, 68),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Muestra un SnackBar de éxito con fondo verde durante 2 segundos.
void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 2),
    ),
  );
}
