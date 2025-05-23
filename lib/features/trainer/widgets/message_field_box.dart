import 'package:flutter/material.dart';

class MessageFieldBox extends StatelessWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final focusNode = FocusNode();
    final ThemeData actualTheme = Theme.of(context);

    final outLineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: actualTheme.colorScheme.secondary),
      borderRadius: BorderRadius.circular(10),
    );

    final inputDecoration = InputDecoration(
      hintText: 'Pregunta lo que quieras!',
      enabledBorder: outLineInputBorder,
      filled: true,
      fillColor: actualTheme.colorScheme.primaryFixed,
      suffixIcon: IconButton(
        icon: Icon(Icons.send_rounded),
        onPressed: () {
          final textValue = textController.value.text;
          if (textValue.isNotEmpty) onValue(textValue);
          textController.clear();
        },
      ),
    );

    return TextFormField(
      onTapOutside: (event) {
        focusNode.unfocus();
      },
      focusNode: focusNode,
      controller: textController,
      decoration: inputDecoration,
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) onValue(value);
        textController.clear();
        focusNode.requestFocus();
      },
    );
  }
}
