import 'package:flutter/material.dart';

/// Widget genérico que muestra una sección con título, lista de ítems y
/// opción de añadir nuevos elementos.
/// - T: tipo de los elementos de la lista.
class SectionCard<T> extends StatefulWidget {
  /// Título de la sección.
  final String title;

  /// Lista de ítems a renderizar.
  final List<T> items;

  /// Constructor de cada ítem, recibe un elemento de tipo T y devuelve un Widget.
  final Widget Function(T) itemBuilder;

  /// Callback opcional que se ejecuta al pulsar el botón de "añadir".
  final VoidCallback? onAdd;

  /// Controla la posición del botón "añadir":
  /// - `false`: aparece junto al título.
  /// - `true`: aparece al final de la lista.
  final bool addButtonAtEnd;

  /// Constructor principal de la tarjeta de sección.
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

/// Estado asociado a [SectionCard].
class _SectionCardState<T> extends State<SectionCard<T>> {
  /// Controlador de scroll para la lista.
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador de scroll cuando se crea el widget.
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    // Liberamos recursos del controlador de scroll al desmontar el widget.
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tema actual para estilos.
    final theme = Theme.of(context);

    return Card(
      // Borde redondeado para la tarjeta.
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            // Encabezado con el título y, opcionalmente, el botón de añadir
            // si addButtonAtEnd es false.
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
            // Contenedor de altura fija con scroll si hay muchos ítems.
            SizedBox(
              height: 250,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                radius: const Radius.circular(12),
                child: ListView.separated(
                  controller: _scrollController,
                  // Si onAdd existe y addButtonAtEnd es true, sumamos 1
                  // para incluir el botón al final.
                  itemCount:
                      widget.items.length +
                      (widget.onAdd != null && widget.addButtonAtEnd ? 1 : 0),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    // Si es la posición final y addButtonAtEnd está activo,
                    // mostramos un botón grande para añadir.
                    if (widget.onAdd != null &&
                        widget.addButtonAtEnd &&
                        index == widget.items.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 24,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: widget.onAdd,
                          icon: const Icon(Icons.add),
                          label: const Text('Añadir'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }
                    // En caso contrario, construimos el ítem usando el builder.
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
