import 'package:flutter/material.dart';

class MessageFieldBox extends StatelessWidget {
  final ValueChanged<String> onValue;

  const MessageFieldBox({super.key, required this.onValue});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final focusNode = FocusNode();

    final colors = Theme.of(context).colorScheme;

    final outLineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colors.primary),
      borderRadius: BorderRadius.circular(10),
    );

    final inputDecoration = InputDecoration(
      hintText: 'Write your message here!',
      enabledBorder: outLineInputBorder,
      filled: true,
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
