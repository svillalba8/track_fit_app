import 'package:flutter/material.dart';

class SectionCard<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T) itemBuilder;
  final VoidCallback? onAdd; // ahora opcional
  final bool addButtonAtEnd; // controla dónde aparece el botón añadir

  const SectionCard({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.onAdd,
    this.addButtonAtEnd = false,
  });

  @override
  State<SectionCard<T>> createState() => _SectionCardState<T>();
}

class _SectionCardState<T> extends State<SectionCard<T>> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            // Header con título, sin botón añadir si addButtonAtEnd es true
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title, style: theme.textTheme.titleMedium),
                if (widget.onAdd != null && !widget.addButtonAtEnd)
                  IconButton(
                    onPressed: widget.onAdd,
                    icon: const Icon(Icons.add_circle_outline),
                    color: Colors.white,
                    splashRadius: 24,
                    tooltip: 'Añadir',
                  ),
              ],
            ),
            const Divider(),
            // Scrollbar + ListView con controlador
            SizedBox(
              height: 250,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(12),
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: widget.items.length + (widget.onAdd != null && widget.addButtonAtEnd ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    // Si es el último y addButtonAtEnd, mostrar botón añadir
                    if (widget.onAdd != null && widget.addButtonAtEnd && index == widget.items.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                        child: ElevatedButton.icon(
                          onPressed: widget.onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      );
                    }
                    final item = widget.items[index];
                    return widget.itemBuilder(item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
