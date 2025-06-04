import 'package:flutter/material.dart';
import 'package:track_fit_app/features/trainer/service/bmi_form.dart';
import 'package:track_fit_app/features/trainer/service/body_fat_form.dart';
import 'package:track_fit_app/features/trainer/service/macros_form.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

// Niveles de popup
enum PopupLevel { menu, form }

class QuickCalculatorsActions extends StatefulWidget {
  final ThemeData actualTheme;
  const QuickCalculatorsActions({super.key, required this.actualTheme});

  @override
  State<QuickCalculatorsActions> createState() =>
      _QuickCalculatorsActionsState();
}

class _QuickCalculatorsActionsState extends State<QuickCalculatorsActions> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final bool _useMetric = true;

  PopupLevel _level = PopupLevel.menu;
  String? _selectedCalculator;

  void _toggleMenu() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _level = PopupLevel.menu;
      _selectedCalculator = null;
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
    const double formWidth = 280;
    const double closeSize = 26;

    final double centerX = position.dx + size.width / 2;
    final double initialLeftUnclamped = centerX - (menuWidth / 1.17);
    final double initialLeft = initialLeftUnclamped.clamp(
      16.0,
      overlay.size.width - menuWidth - 16.0,
    );

    final double top = position.dy + (size.height / 2) - (closeSize / 1.06);

    return OverlayEntry(
      builder: (context) {
        final double popupWidth =
            _level == PopupLevel.menu ? menuWidth : formWidth;

        // Empiezas con la misma izquierda del menú
        double left = initialLeft;

        // Si es el popup de formulario, lo desplazas 20px a la izquierda
        if (_level == PopupLevel.form) {
          left -= 100; // ajusta este valor a tu gusto
        }

        // Luego aseguras los márgenes mínimos y máximos
        left = left.clamp(16.0, overlay.size.width - popupWidth - 16.0);

        return Positioned(
          left: left,
          top: top,
          width: popupWidth,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child:
                _level == PopupLevel.menu
                    ? _buildMenuContent()
                    : _buildFormContent(),
          ),
        );
      },
    );
  }

  Widget _buildMenuContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.actualTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: cambio de unidades y cerrar
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // setState(() => _useMetric = !_useMetric); Actualizacion futura
                  _overlayEntry?.markNeedsBuild();
                },
                child: Icon(
                  _useMetric ? Icons.straighten_rounded : Icons.height_rounded, // Implementacion futura
                  size: 32,
                  color: widget.actualTheme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _useMetric ? 'kg / cm' : 'lb / in',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'TIPO',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),
          CustomDivider(),
          const SizedBox(height: 18),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _menuIcon('assets/icons/porcentaje.png', 'GRASA', () {
                setState(() {
                  _level = PopupLevel.form;
                  _selectedCalculator = '% de grasa';
                });
                _overlayEntry?.markNeedsBuild();
              }),

              const SizedBox(height: 18),

              _menuIcon('assets/icons/bmi.png', 'IMC', () {
                setState(() {
                  _level = PopupLevel.form;
                  _selectedCalculator = 'IMC';
                });
                _overlayEntry?.markNeedsBuild();
              }),

              const SizedBox(height: 18),

              _menuIcon('assets/icons/macros.png', 'MACROS', () {
                setState(() {
                  _level = PopupLevel.form;
                  _selectedCalculator = 'macros';
                });
                _overlayEntry?.markNeedsBuild();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    final actualTheme = Theme.of(context);

    // Selecciona el widget de formulario según lo elegido
    late final Widget form;
    switch (_selectedCalculator) {
      case '% de grasa':
        form = BodyFatForm(useMetric: _useMetric);
        break;
      case 'IMC':
        form = BmiForm(useMetric: _useMetric);
        break;
      case 'macros':
        form = MacrosForm(useMetric: _useMetric, onCalculated: _toggleMenu);
        break;
      default:
        form = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.actualTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flecha de retroceso y título dinámico
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedCalculator?.toUpperCase() ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _level = PopupLevel.menu);
                  _overlayEntry?.markNeedsBuild();
                },
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: actualTheme.colorScheme.secondary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDivider(),
          const SizedBox(height: 12),
          // Aquí se inserta el formulario correspondiente
          form,
        ],
      ),
    );
  }

  Widget _menuIcon(String assetPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            assetPath,
            width: 32,
            height: 32,
            color: widget.actualTheme.colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
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
