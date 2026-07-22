import 'package:flutter/material.dart';
import '../../../core/models/tooth.dart';

class SurfaceDiagramPainter extends CustomPainter {
  final Set<Surface> selectedSurfaces;
  final bool isAnterior;

  SurfaceDiagramPainter({
    required this.selectedSurfaces,
    required this.isAnterior,
  });

  // Common styles
  static const Color outlineColor = Color(0xFF37474F);
  static const Color fillColor = Color(0x331565C0); // 20% opacity blue
  static const double strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the 5 zones
    _drawZone(canvas, size, Surface.occlusal); // Center
    _drawZone(canvas, size, Surface.buccal);   // Top
    _drawZone(canvas, size, Surface.lingual);  // Bottom
    _drawZone(canvas, size, Surface.mesial);   // Left
    _drawZone(canvas, size, Surface.distal);   // Right

    // Draw labels outside
    _drawLabel(canvas, size, Surface.buccal, isAnterior ? "Labial" : "Buccal");
    _drawLabel(canvas, size, Surface.lingual, isAnterior ? "Palatal" : "Lingual");
    _drawLabel(canvas, size, Surface.mesial, "Mesial");
    _drawLabel(canvas, size, Surface.distal, "Distal");
    _drawLabel(canvas, size, Surface.occlusal, isAnterior ? "Incisal" : "Occlusal");
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
    
    // We create a rounded rectangle divided into 5 zones.
    // Let's define the outer box and inner box.
    final double padding = 30.0; // Space for labels
    final Rect outerRect = Rect.fromLTRB(padding, padding, w - padding, h - padding);
    final Rect innerRect = Rect.fromCenter(
      center: outerRect.center,
      width: outerRect.width * 0.4,
      height: outerRect.height * 0.4,
    );

    final Path path = Path();

    switch (surface) {
      case Surface.occlusal:
        path.addRRect(RRect.fromRectAndRadius(innerRect, const Radius.circular(8)));
        break;
      case Surface.buccal: // Top
        path.moveTo(outerRect.left, outerRect.top);
        path.lineTo(outerRect.right, outerRect.top);
        path.lineTo(innerRect.right, innerRect.top);
        path.lineTo(innerRect.left, innerRect.top);
        path.close();
        break;
      case Surface.lingual: // Bottom
        path.moveTo(innerRect.left, innerRect.bottom);
        path.lineTo(innerRect.right, innerRect.bottom);
        path.lineTo(outerRect.right, outerRect.bottom);
        path.lineTo(outerRect.left, outerRect.bottom);
        path.close();
        break;
      case Surface.mesial: // Left
        path.moveTo(outerRect.left, outerRect.top);
        path.lineTo(innerRect.left, innerRect.top);
        path.lineTo(innerRect.left, innerRect.bottom);
        path.lineTo(outerRect.left, outerRect.bottom);
        path.close();
        break;
      case Surface.distal: // Right
        path.moveTo(innerRect.right, innerRect.top);
        path.lineTo(outerRect.right, outerRect.top);
        path.lineTo(outerRect.right, outerRect.bottom);
        path.lineTo(innerRect.right, innerRect.bottom);
        path.close();
        break;
    }

    return path;
  }

  void _drawLabel(Canvas canvas, Size size, Surface surface, String text) {
    final textStyle = const TextStyle(
      color: Color(0xFF37474F),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final padding = 30.0;
    final center = Offset(size.width / 2, size.height / 2);
    
    double dx = 0;
    double dy = 0;

    switch (surface) {
      case Surface.buccal:
        dx = center.dx - textPainter.width / 2;
        dy = padding / 2 - textPainter.height / 2;
        break;
      case Surface.lingual:
        dx = center.dx - textPainter.width / 2;
        dy = size.height - padding / 2 - textPainter.height / 2;
        break;
      case Surface.mesial:
        dx = padding / 2 - textPainter.width / 2;
        dy = center.dy - textPainter.height / 2;
        break;
      case Surface.distal:
        dx = size.width - padding / 2 - textPainter.width / 2;
        dy = center.dy - textPainter.height / 2;
        break;
      case Surface.occlusal:
        dx = center.dx - textPainter.width / 2;
        dy = center.dy - textPainter.height / 2;
        break;
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
        oldDelegate.isAnterior != isAnterior;
  }
}
