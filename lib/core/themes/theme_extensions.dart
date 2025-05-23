// lib/core/theme_extensions.dart
import 'package:flutter/material.dart';

@immutable
class ChatBackground extends ThemeExtension<ChatBackground> {
  final String assetPath;

  const ChatBackground({required this.assetPath});

  @override
  ChatBackground copyWith({String? assetPath}) {
    return ChatBackground(assetPath: assetPath ?? this.assetPath);
  }

  @override
  ChatBackground lerp(ThemeExtension<ChatBackground>? other, double t) {
    if (other is! ChatBackground) return this;
    // como es String, no interpolamos — devolvemos uno u otro según t
    return t < 0.5 ? this : other;
  }
}
