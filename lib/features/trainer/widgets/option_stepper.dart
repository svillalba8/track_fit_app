import 'package:flutter/material.dart';

class OptionStepper extends StatefulWidget {
  final String label;
  final List<String> options;
  final int initialIndex;
  final ValueChanged<String>? onChanged;
  final IconData upIcon;
  final IconData downIcon;

  const OptionStepper({
    super.key,
    required this.label,
    required this.options,
    this.initialIndex = 2,
    this.onChanged,
    this.upIcon = Icons.keyboard_arrow_up,
    this.downIcon = Icons.keyboard_arrow_down,
  });

  @override
  _OptionStepperState createState() => _OptionStepperState();
}

class _OptionStepperState extends State<OptionStepper> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex.clamp(0, widget.options.length - 1);
  }

  void _increment() {
    setState(() {
      if (currentIndex < widget.options.length - 1) {
        currentIndex++;
      }
      widget.onChanged?.call(widget.options[currentIndex]);
    });
  }

  void _decrement() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
      widget.onChanged?.call(widget.options[currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData actualTheme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '- ${widget.label}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.options[currentIndex],
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              const SizedBox(width: 16),

              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: actualTheme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.upIcon,
                        size: 22, // tamaño del icono
                        color: actualTheme.colorScheme.primary,
                      ),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                      onPressed: _increment,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: actualTheme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            widget.downIcon,
                            size: 22, // tamaño del icono
                            color: actualTheme.colorScheme.primary,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          splashRadius: 16,
                          onPressed: _decrement,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
