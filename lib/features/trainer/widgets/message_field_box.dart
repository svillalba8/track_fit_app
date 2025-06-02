import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: TextFormField(
        controller: _textController,
        focusNode: _focusNode,
        minLines: 1,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.send,
        onFieldSubmitted: _handleSubmit,
        decoration: InputDecoration(
          hintText: 'Pregunta lo que quieras…',
          filled: true,
          fillColor: actualTheme.colorScheme.surface,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: actualTheme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon:
              _hasText
                  ? IconButton(
                    icon: Icon(Icons.send_rounded),
                    color: actualTheme.colorScheme.secondary,
                    onPressed: _handleSubmit,
                    tooltip: 'Enviar mensaje',
                  )
                  : null,
        ),
        onTapOutside: (_) => _focusNode.unfocus(),
      ),
    );
  }
}
