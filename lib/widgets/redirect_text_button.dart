import 'package:flutter/material.dart';

class RedirectTextButton extends StatefulWidget {
  final Function()? function;
  final String text;
  final Color textColor;

  const RedirectTextButton({
    super.key,
    required this.function,
    required this.text,
    required this.textColor
  });

  @override
  State<RedirectTextButton> createState() => _RedirectTextButtonState();
}

class _RedirectTextButtonState extends State<RedirectTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.function ?? () {},
      child: Text(
        widget.text,
        style: TextStyle(fontSize: 13, color: widget.textColor),
      ),
    );
  }
}
