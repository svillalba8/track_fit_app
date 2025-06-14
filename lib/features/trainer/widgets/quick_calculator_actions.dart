import 'package:flutter/material.dart';
import 'package:track_fit_app/features/trainer/service/bmi_form.dart';
import 'package:track_fit_app/features/trainer/service/body_fat_form.dart';
import 'package:track_fit_app/features/trainer/service/macros_form.dart';
import 'package:track_fit_app/widgets/custom_divider.dart';
import 'package:track_fit_app/widgets/custom_icon_button.dart';

/// Niveles del popup: menú principal o formulario concreto
enum PopupLevel { menu, form }

/// Botón de “calculadoras rápidas” que muestra un menú overlay
class QuickCalculatorsActions extends StatefulWidget {
  final ThemeData actualTheme;
  const QuickCalculatorsActions({super.key, required this.actualTheme});

  @override
  State<QuickCalculatorsActions> createState() =>
      _QuickCalculatorsActionsState();
}

class _QuickCalculatorsActionsState extends State<QuickCalculatorsActions> {
  final LayerLink _layerLink = LayerLink(); // Enlaza target y overlay
  OverlayEntry? _overlayEntry; // Guarda el overlay abierto
  final bool _useMetric = true; // Unidades (futuro toggle)

  PopupLevel _level = PopupLevel.menu; // Nivel actual (menu o form)
  String? _selectedCalculator; // Tipo de calculadora elegido

  /// Muestra u oculta el overlay
  void _toggleMenu() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
      // Restablece al menú
      _level = PopupLevel.menu;
      _selectedCalculator = null;
    }
  }

  /// Crea el overlay posicionando el menú o el formulario
  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);

    const menuWidth = 180.0;
    const formWidth = 280.0;
    const closeSize = 26.0;

    // Calcula posición horizontal centrada y ajusta a pantallas pequeñas
    final centerX = position.dx + size.width / 2;
    final initialLeftUnclamped = centerX - (menuWidth / 1.17);
    var left = initialLeftUnclamped.clamp(
      16.0,
      overlay.size.width - menuWidth - 16.0,
    );

    final top = position.dy + (size.height / 2) - (closeSize / 1.06);

    return OverlayEntry(
      builder: (context) {
        // Decide ancho según nivel
        final popupWidth = _level == PopupLevel.menu ? menuWidth : formWidth;
        // Desplaza el form ligeramente a la izquierda
        var adjustedLeft = left - (_level == PopupLevel.form ? 100 : 0);
        adjustedLeft = adjustedLeft.clamp(
          16.0,
          overlay.size.width - popupWidth - 16.0,
        );

        return Positioned(
          left: adjustedLeft,
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

  /// Construye el contenido del menú con opciones de calculadora
  Widget _buildMenuContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.actualTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado: cierre y cambio de unidades (no implementado)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  _overlayEntry?.markNeedsBuild();
                },
                child: Icon(
                  _useMetric ? Icons.straighten_rounded : Icons.height_rounded,
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
                onTap: _toggleMenu, // Cierra el menú
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
          // Opciones: grasa corporal, IMC, macros
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

  /// Construye el formulario correspondiente al tipo seleccionado
  Widget _buildFormContent() {
    final theme = Theme.of(context);
    // Escoge el widget de formulario
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
        children: [
          // Encabezado con título y botón de volver
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
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CustomDivider(),
          const SizedBox(height: 12),
          form, // Inserta el formulario
        ],
      ),
    );
  }

  /// Fila de icono y etiqueta para el menú
  Widget _menuIcon(String assetPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
    // Botón que activa el overlay, envolviendo en CompositedTransformTarget
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
        onPressed: _toggleMenu, // Muestra/oculta el menú
      ),
    );
  }
}
