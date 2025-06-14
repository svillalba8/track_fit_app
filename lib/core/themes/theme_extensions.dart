import 'package:flutter/material.dart';

@immutable
class ChatBackground extends ThemeExtension<ChatBackground> {
  /// Ruta del asset de imagen para el fondo de chat
  final String assetPath;

  const ChatBackground({required this.assetPath});

  /// Devuelve una copia con posibles campos modificados
  @override
  ChatBackground copyWith({String? assetPath}) {
    return ChatBackground(assetPath: assetPath ?? this.assetPath);
  }

  /// Interpola entre dos extensiones de tema (no hace interpolación real de String)
  @override
  ChatBackground lerp(ThemeExtension<ChatBackground>? other, double t) {
    if (other is! ChatBackground) return this;
    // Si t < 0.5 devuelve this, sino devuelve other
    return t < 0.5 ? this : other;
  }
}
