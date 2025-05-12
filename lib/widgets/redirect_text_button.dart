import 'package:flutter/material.dart';

class RedirectTextButton extends StatefulWidget {
  final Function()? function;
  final String text;

  const RedirectTextButton({super.key, required this.function, required this.text});

  @override
  State<RedirectTextButton> createState() => _RedirectTextButtonState();
}

class _RedirectTextButtonState extends State<RedirectTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.function ?? () {},
      child: Text(widget.text, style: TextStyle(fontSize: 13)),
    );
  }
}
