import 'package:flutter/material.dart';

class RedirectTextButton extends StatefulWidget {
  // Función a ejecutar al pulsar el botón (opcional)
  final Function()? function;
  // Texto que muestra el botón
  final String text;
  // Color del texto
  final Color textColor;

  const RedirectTextButton({
    super.key,
    required this.function,
    required this.text,
    required this.textColor,
  });

  @override
  State<RedirectTextButton> createState() => _RedirectTextButtonState();
}

class _RedirectTextButtonState extends State<RedirectTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      // Ejecuta la función proporcionada o una función vacía si es null
      onPressed: widget.function ?? () {},
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 13, color: widget.textColor),
      ),
    );
  }
}
