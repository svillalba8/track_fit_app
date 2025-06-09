import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/features/home/service/hydration_service.dart';

class HydrationWidget extends StatelessWidget {
  const HydrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el HydrationNotifier
    final hydration = context.watch<HydrationNotifier>();

const int kCapacidadTotalMl = 8000;
const int kCantidadAguaVaso = 250;
const int kCantidadAguaBotella = 1000;

    // Constantes para el vaso y botones
    const double vasoWidth = 40.0;
    const double vasoHeight = 70.0;
    const double textSpace = 24.0;
    const double espacioEntreBotones = 12.0;

    final theme = Theme.of(context);

    // 1) Si todavía está cargando los datos iniciales:
    if (hydration.isHydrationLoading) {
      return SizedBox(
        height: 86,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.secondary),
        ),
      );
    }

    // 2) Si hubo error al leer/crear el registro:
    if (hydration.hydrationError != null) {
      return SizedBox(
        height: 86,
        child: Center(
          child: Text(
            hydration.hydrationError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // 3) Ya tenemos mlBebidos cargado en el notifier
    final mlBebidos = hydration.mlBebidos;
    final nivel = (mlBebidos / kCapacidadTotalMl).clamp(0.0, 1.0);

    return SizedBox(
      height: vasoHeight + 16, // aprox. 86 px en total
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 3.1) Botones a la izquierda, alineados verticalmente
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón +250 ml
              GestureDetector(
                onTap: () {
                  hydration.addWater(context, kCantidadAguaVaso);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        color: Colors.black.withAlpha((0.3 * 255).round()),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.local_drink,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: espacioEntreBotones),

              // Botón +1000 ml
              GestureDetector(
                onTap: () {
                  hydration.addWater(context ,kCantidadAguaBotella);
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                        color: Colors.black.withAlpha((0.3 * 255).round()),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: ImageIcon(
                      AssetImage('assets/icons/botella_agua.png'),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 40),

          // 3.2) Vaso con espacio extra a la derecha para texto
          SizedBox(
            width: vasoWidth + textSpace,
            height: vasoHeight,
            child: CustomPaint(
              size: const Size(vasoWidth + textSpace, vasoHeight),
              painter: _GlassPainter(
                nivel: nivel,
                vasoWidth: vasoWidth,
                textSpace: textSpace,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Copia exactamente el mismo GlassPainter que tenías antes:
class _GlassPainter extends CustomPainter {
  final double nivel; // 0.0–1.0, porcentaje de llenado visual
  final double vasoWidth; // ancho interior del vaso
  final double textSpace; // espacio reservado para texto a la derecha

  _GlassPainter({
    required this.nivel,
    required this.vasoWidth,
    required this.textSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double glassW = vasoWidth;
    final double glassH = size.height;

    final paintOutline =
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    final paintWater =
        Paint()
          ..color = const Color(0xFF007AFF)
          ..style = PaintingStyle.fill;

    final paintMark =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1;

    // 1) Definir el Path del vaso (trapezoide invertido)
    final Path vasoPath =
        Path()
          ..moveTo(0, 0)
          ..lineTo(glassW, 0)
          ..lineTo(glassW * 0.8, glassH)
          ..lineTo(glassW * 0.2, glassH)
          ..close();

    // 2) Pintar el agua dentro del trapezoide
    canvas.save();
    canvas.clipPath(vasoPath);
    final double aguaHeight = glassH * nivel;
    final Rect aguaRect = Rect.fromLTWH(
      0,
      glassH - aguaHeight,
      glassW,
      aguaHeight,
    );
    canvas.drawRect(aguaRect, paintWater);
    canvas.restore();

    // 3) Dibujar marcas cortas y etiquetas (“6 L”, “4 L”, “2 L”)
    const int numMarcas = 3;
    const double longitudMarca = 6.0;
    const double offsetInterno = 4.0;
    const double textoOffsetX = 4.0;
    final TextStyle textoStyle = TextStyle(
      color: Colors.black,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    for (int i = 1; i <= numMarcas; i++) {
      final double frac = i / (numMarcas + 1); // 0.25, 0.50, 0.75
      final double y = glassH * frac;

      final double xRightEdge = glassW - (glassW * 0.2 * frac);
      final double xMarkStart = xRightEdge - offsetInterno;

      // Dibujar la línea corta
      canvas.drawLine(
        Offset(xMarkStart, y),
        Offset(xMarkStart - longitudMarca, y),
        paintMark,
      );

      // Etiqueta en orden inverso: (numMarcas + 1 - i) * 2 L
      final String textoLitros = '${(numMarcas + 1 - i) * 2} L';
      final textSpan = TextSpan(text: textoLitros, style: textoStyle);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();

      // Dibujar el texto fuera del vaso, a la derecha
      final double textoX = glassW + textoOffsetX;
      final double textoY = y - (tp.height / 2);
      tp.paint(canvas, Offset(textoX, textoY));
    }

    // 4) Dibujar contorno del vaso
    canvas.drawPath(vasoPath, paintOutline);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldPainter) {
    return oldPainter.nivel != nivel;
  }
}
