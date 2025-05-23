import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

class QuickCalculatorsActions extends StatefulWidget {
  final ThemeData actualTheme;
  const QuickCalculatorsActions({super.key, required this.actualTheme});

  @override
  _QuickCalculatorsActionsState createState() =>
      _QuickCalculatorsActionsState();
}

class _QuickCalculatorsActionsState extends State<QuickCalculatorsActions> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _useMetric = true;

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset position = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    const double menuWidth = 180;
    const double closeSize = 26;
    // NO TOCAR POSICIÓN
    double left = position.dx + (size.width / 2) - (menuWidth / 1.15);
    left = left.clamp(16.0, overlay.size.width - menuWidth - 16.0);
    final double top = position.dy + (size.height / 2) - (closeSize / 1.1);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: left,
            top: top,
            width: menuWidth,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.actualTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _useMetric = !_useMetric);
                              _overlayEntry?.markNeedsBuild();
                            },
                            child: Icon(
                              _useMetric
                                  ? Icons
                                      .straighten_rounded // Ejemplo: icono métrico
                                  : Icons
                                      .height_rounded, // Ejemplo: icono imperial
                              size: 32,
                              color: widget.actualTheme.colorScheme.secondary,
                            ),
                          ),
                        ),

                        SizedBox(width: _useMetric ? 8 : 2),

                        Expanded(
                          child: Text(
                            _useMetric ? 'kg / cm' : 'lb / in',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleMenu,
                          child: Icon(
                            Icons.close_rounded,
                            size: 26,
                            color: widget.actualTheme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    Center(
                      child: Text(
                        'TIPO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.actualTheme.colorScheme.secondary,
                        ),
                      ),
                    ),

                    SizedBox(height: 6),

                    Divider(
                      height: 1,
                      thickness: 1,
                      color: widget.actualTheme.colorScheme.secondary.withAlpha(
                        (0.4 * 255).round(),
                      ),
                    ),

                    SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _menuIcon(
                          'assets/icons/porcentaje.png',
                          () => context.go(
                            '/calculator/percentFat',
                            extra: {'useMetric': _useMetric},
                          ),
                        ),
                        _menuIcon(
                          'assets/icons/bmi.png',
                          () => context.go(
                            '/calculator/bmi',
                            extra: {'useMetric': _useMetric},
                          ),
                        ),
                        _menuIcon(
                          'assets/icons/macros.png',
                          () => context.go(
                            '/calculator/macros',
                            extra: {'useMetric': _useMetric},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _menuIcon(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
        _toggleMenu();
      },
      child: Image.asset(
        assetPath,
        width: 32,
        height: 32,
        color: widget.actualTheme.colorScheme.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomIconButton(
        icon: Image.asset(
          'assets/icons/calculadora.png',
          width: 26,
          height: 26,
          color: widget.actualTheme.colorScheme.secondary,
        ),
        actualTheme: widget.actualTheme,
        onPressed: _toggleMenu,
      ),
    );
  }
}
