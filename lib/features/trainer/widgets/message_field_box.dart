import 'package:flutter/material.dart';

/// Caja de texto para enviar mensajes en el chat, con botón de envío animado
class MessageFieldBox extends StatefulWidget {
  // Callback que recibe el texto al enviarse
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _hasText = false; // Controla visibilidad del icono de enviar

  @override
  void initState() {
    super.initState();
    // Listener para habilitar/deshabilitar el botón según contenido
    _textController =
        TextEditingController()..addListener(() {
          setState(() {
            _hasText = _textController.text.trim().isNotEmpty;
          });
        });
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Envía el mensaje si no está vacío, limpia el campo y recupera foco
  void _handleSubmit([String? value]) {
    final text = (value ?? _textController.text).trim();
    if (text.isEmpty) return;
    widget.onValue(text);
    _textController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final actualTheme = Theme.of(context);
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: actualTheme.colorScheme.secondary),
      borderRadius: BorderRadius.circular(16),
    );

    return AnimatedPadding(
      // Ajusta padding inferior al aparecer teclado
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: TextFormField(
        controller: _textController, // Controla el contenido
        focusNode: _focusNode, // Gestiona el enfoque
        minLines: 1,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        onFieldSubmitted: _handleSubmit, // Envía al pulsar "Enviar"
        decoration: InputDecoration(
          hintText: 'Pregunta lo que quieras…',
          filled: true,
          fillColor: actualTheme.colorScheme.surface,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(color: actualTheme.colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          // Muestra icono de enviar solo si hay texto
          suffixIcon:
              _hasText
                  ? IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: actualTheme.colorScheme.secondary,
                    onPressed: _handleSubmit,
                    tooltip: 'Enviar mensaje',
                  )
                  : null,
        ),
        onTapOutside:
            (_) => _focusNode.unfocus(), // Oculta teclado al tocar fuera
      ),
    );
  }
}
