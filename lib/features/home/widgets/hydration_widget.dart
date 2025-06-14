import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:track_fit_app/notifiers/hydration_notifier.dart';

// Widget que muestra el nivel de hidratación y botones para añadir agua
class HydrationWidget extends StatelessWidget {
  const HydrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el estado de hidratación mediante Provider
    final hydration = context.watch<HydrationNotifier>();

    // Constantes de capacidad total y tamaños de incrementos
    const int kCapacidadTotalMl = 8000; // 8 litros diarios
    const int kCantidadAguaVaso = 250; // 250 ml por vaso
    const int kCantidadAguaBotella = 1000; // 1 litro por botella

    // Dimensiones para el dibujo del vaso y disposición de botones
    const double vasoWidth = 40.0;
    const double vasoHeight = 90.0;
    const double textSpace = 24.0; // espacio para etiquetas de litros
    const double espacioEntreBotones = 10;

    final theme = Theme.of(context);

    // 1) Mientras se carga el registro de hidratación:
    if (hydration.isHydrationLoading) {
      return SizedBox(
        height: vasoHeight - 4,
        child: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.secondary),
        ),
      );
    }

    // 2) Si ocurre un error al cargar o crear el registro:
    if (hydration.hydrationError != null) {
      return SizedBox(
        height: vasoHeight - 4,
        child: Center(
          child: Text(
            hydration.hydrationError!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // 3) Ya tenemos mlBebidos actualizado
    final mlBebidos = hydration.mlBebidos;
    // Normalizamos el nivel entre 0.0 y 1.0 para el porcentaje de llenado
    final nivel = (mlBebidos / kCapacidadTotalMl).clamp(0.0, 1.0);

    return SizedBox(
      height: vasoHeight + 28, // altura total incluyendo botones
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 3.1) Columna de botones para añadir agua
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón para sumar 250 ml
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
              const SizedBox(height: 4),
              // Etiqueta del botón de vaso
              Text(
                '+250ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),

              const SizedBox(height: espacioEntreBotones),

              // Botón para sumar 1000 ml
              GestureDetector(
                onTap: () {
                  hydration.addWater(context, kCantidadAguaBotella);
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
              const SizedBox(height: 4),
              // Etiqueta del botón de botella
              Text(
                '+1000ml',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),

          const SizedBox(width: 30),

          // 3.2) Dibujo del vaso con nivel de agua y marcas
          SizedBox(
            width: vasoWidth + textSpace,
            height: vasoHeight,
            child: CustomPaint(
              size: Size(vasoWidth + textSpace, vasoHeight),
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

// Pintor personalizado que dibuja el vaso, el agua y las marcas de litros
class _GlassPainter extends CustomPainter {
  final double nivel; // Proporción de llenado (0.0–1.0)
  final double vasoWidth; // Ancho interior del vaso
  final double textSpace; // Espacio para etiquetas a la derecha

  _GlassPainter({
    required this.nivel,
    required this.vasoWidth,
    required this.textSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double glassW = vasoWidth;
    final double glassH = size.height;

    // Paint para contorno del vaso
    final paintOutline =
        Paint()
          ..color = Colors.grey.shade400
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    // Paint para el agua
    final paintWater =
        Paint()
          ..color = const Color(0xFF007AFF)
          ..style = PaintingStyle.fill;

    // Paint para marcas de nivel
    final paintMark =
        Paint()
          ..color = Colors.grey.shade400
          ..strokeWidth = 1;

    // 1) Definición del Path en forma de trapezoide invertido
    final Path vasoPath =
        Path()
          ..moveTo(0, 0)
          ..lineTo(glassW, 0)
          ..lineTo(glassW * 0.8, glassH)
          ..lineTo(glassW * 0.2, glassH)
          ..close();

    // 2) Dibuja el rectángulo de agua dentro del Path del vaso
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

    // 3) Dibuja marcas y etiquetas "2L", "4L", "6L"
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
      final double frac = i / (numMarcas + 1);
      final double y = glassH * frac;

      // Calcula posición horizontal de la marca según ancho trapezoide
      final double xRightEdge = glassW - (glassW * 0.2 * frac);
      final double xMarkStart = xRightEdge - offsetInterno;

      // Dibuja línea de la marca
      canvas.drawLine(
        Offset(xMarkStart, y),
        Offset(xMarkStart - longitudMarca, y),
        paintMark,
      );

      // Etiqueta de litros en orden inverso: 6L,4L,2L
      final String textoLitros = '${(numMarcas + 1 - i) * 2}L';
      final textSpan = TextSpan(text: textoLitros, style: textoStyle);
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();

      // Pinta texto justo afuera del vaso
      final double textoX = glassW + textoOffsetX;
      final double textoY = y - (tp.height / 2);
      tp.paint(canvas, Offset(textoX, textoY));
    }

    // 4) Dibuja el contorno del vaso encima de todo
    canvas.drawPath(vasoPath, paintOutline);
  }

  @override
  bool shouldRepaint(covariant _GlassPainter oldPainter) {
    // Repinta solo si cambia el nivel de agua
    return oldPainter.nivel != nivel;
  }
}
