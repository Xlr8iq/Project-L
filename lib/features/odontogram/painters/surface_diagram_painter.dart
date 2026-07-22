import 'package:flutter/material.dart';
import '../../../core/models/tooth.dart';

class SurfaceDiagramPainter extends CustomPainter {
  final Set<Surface> selectedSurfaces;
  final bool isAnterior;
  final bool isUpper;

  SurfaceDiagramPainter({
    required this.selectedSurfaces,
    required this.isAnterior,
    required this.isUpper,
  });

  static const Color outlineColor = Color(0xFF37474F);
  static const Color fillColor = Color(0x331565C0); // 20% opacity blue
  static const double strokeWidth = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    // ─── Draw the 5 zones ───
    _drawZone(canvas, size, Surface.occlusal); // Center
    _drawZone(canvas, size, Surface.buccal);   // Top (Labial/Buccal)
    _drawZone(canvas, size, Surface.lingual);  // Bottom (Lingual/Palatal)
    _drawZone(canvas, size, Surface.mesial);   // Left
    _drawZone(canvas, size, Surface.distal);   // Right

    // ─── Draw Labels matching reference image ───
    final topLabel = isAnterior ? "Incisal" : "Occlusal";
    final bottomLabel = isUpper ? "Lingual\n(Palatal)" : "Lingual\n(Buccal)";
    
    _drawLabel(canvas, size, Surface.buccal, topLabel, isTop: true);
    _drawLabel(canvas, size, Surface.lingual, bottomLabel, isBottom: true);
    _drawLabel(canvas, size, Surface.mesial, "Mesial", isLeft: true);
    _drawLabel(canvas, size, Surface.distal, "Distal", isRight: true);
  }

  void _drawZone(Canvas canvas, Size size, Surface surface) {
    final path = _getZonePath(surface, size);
    
    if (selectedSurfaces.contains(surface)) {
      final paintFill = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paintFill);
    }

    final paintStroke = Paint()
      ..color = outlineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    
    canvas.drawPath(path, paintStroke);
  }

  static Path _getZonePath(Surface surface, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Outer diagram rect (centered with padding for labels)
    final double padding = 28.0;
    final Rect outerRect = Rect.fromLTRB(padding, padding, w - padding, h - padding);
    
    // Inner center rect (38% of outer size)
    final Rect innerRect = Rect.fromCenter(
      center: outerRect.center,
      width: outerRect.width * 0.38,
      height: outerRect.height * 0.38,
    );

    final Path path = Path();

    switch (surface) {
      case Surface.occlusal: // Center square
        path.addRect(innerRect);
        break;
      case Surface.buccal: // Top trapezoid
        path.moveTo(outerRect.left, outerRect.top);
        path.lineTo(outerRect.right, outerRect.top);
        path.lineTo(innerRect.right, innerRect.top);
        path.lineTo(innerRect.left, innerRect.top);
        path.close();
        break;
      case Surface.lingual: // Bottom trapezoid
        path.moveTo(innerRect.left, innerRect.bottom);
        path.lineTo(innerRect.right, innerRect.bottom);
        path.lineTo(outerRect.right, outerRect.bottom);
        path.lineTo(outerRect.left, outerRect.bottom);
        path.close();
        break;
      case Surface.mesial: // Left trapezoid
        path.moveTo(outerRect.left, outerRect.top);
        path.lineTo(innerRect.left, innerRect.top);
        path.lineTo(innerRect.left, innerRect.bottom);
        path.lineTo(outerRect.left, outerRect.bottom);
        path.close();
        break;
      case Surface.distal: // Right trapezoid
        path.moveTo(innerRect.right, innerRect.top);
        path.lineTo(outerRect.right, outerRect.top);
        path.lineTo(outerRect.right, outerRect.bottom);
        path.lineTo(innerRect.right, innerRect.bottom);
        path.close();
        break;
    }

    return path;
  }

  void _drawLabel(
    Canvas canvas,
    Size size,
    Surface surface,
    String text, {
    bool isTop = false,
    bool isBottom = false,
    bool isLeft = false,
    bool isRight = false,
  }) {
    final textStyle = const TextStyle(
      color: Color(0xFF424242),
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.1,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final padding = 28.0;
    final center = Offset(size.width / 2, size.height / 2);
    
    double dx = 0;
    double dy = 0;

    if (isTop) {
      dx = center.dx - textPainter.width / 2;
      dy = padding / 2 - textPainter.height / 2;
    } else if (isBottom) {
      dx = center.dx - textPainter.width / 2;
      dy = size.height - padding / 2 - textPainter.height / 2;
    } else if (isLeft) {
      dx = (padding / 2) - (textPainter.width / 2);
      dy = center.dy - textPainter.height / 2;
    } else if (isRight) {
      dx = size.width - (padding / 2) - (textPainter.width / 2);
      dy = center.dy - textPainter.height / 2;
    }

    textPainter.paint(canvas, Offset(dx, dy));
  }

  static Surface? hitTestSurface(Offset position, Size size) {
    for (var surface in Surface.values) {
      final path = _getZonePath(surface, size);
      if (path.contains(position)) {
        return surface;
      }
    }
    return null;
  }

  @override
  bool shouldRepaint(covariant SurfaceDiagramPainter oldDelegate) {
    return oldDelegate.selectedSurfaces != selectedSurfaces ||
        oldDelegate.isAnterior != isAnterior ||
        oldDelegate.isUpper != isUpper;
  }
}
