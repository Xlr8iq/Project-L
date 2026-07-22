import 'package:flutter/material.dart';
import '../../../core/models/tooth.dart';

class ToothPainter extends CustomPainter {
  final ToothShape shape;
  final bool isUpper;
  final bool isSelected;
  final ProcedureType procedure;
  final Color? procedureColor;

  ToothPainter({
    required this.shape,
    required this.isUpper,
    required this.isSelected,
    required this.procedure,
    this.procedureColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path fullPath = getToothPath(shape, size, isUpper);

    // Procedure Color Overlay Fill
    if (procedure != ProcedureType.none && procedureColor != null) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = procedureColor!.withOpacity(0.35);
      
      canvas.save();
      // Clip to crown region
      if (isUpper) {
        canvas.clipRect(Rect.fromLTRB(0, size.height * 0.45, size.width, size.height));
      } else {
        canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height * 0.55));
      }
      canvas.drawPath(fullPath, fillPaint);
      canvas.restore();
    }

    final outlineColor = isSelected ? const Color(0xFF1565C0) : const Color(0xFF37474F);
    final outlineWidth = isSelected ? 2.5 : 1.5;

    // Main Outer Contour Stroke
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = outlineColor
      ..strokeWidth = outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fullPath, strokePaint);

    // Anatomical Inner Detail Lines (CEJ, Cusp Grooves)
    final detailPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = isSelected ? const Color(0xFF1976D2) : const Color(0xFF78909C)
      ..strokeWidth = 1.0;

    _drawAnatomicalDetails(canvas, size, shape, isUpper, detailPaint);
  }

  void _drawAnatomicalDetails(Canvas canvas, Size size, ToothShape shape, bool isUpper, Paint paint) {
    final w = size.width;
    final h = size.height;
    final cejY = isUpper ? h * 0.55 : h * 0.45;

    // Cementoenamel Junction (CEJ) curved boundary line
    final cejPath = Path();
    cejPath.moveTo(w * 0.22, cejY);
    cejPath.quadraticBezierTo(w * 0.5, isUpper ? cejY + (h * 0.05) : cejY - (h * 0.05), w * 0.78, cejY);
    canvas.drawPath(cejPath, paint);

    // Occlusal / Cusp fissure lines for posterior teeth (Premolars and Molars)
    if (shape == ToothShape.firstMolar || shape == ToothShape.secondMolar || shape == ToothShape.thirdMolar) {
      final grooveY = isUpper ? h * 0.82 : h * 0.18;
      final groovePath = Path();
      groovePath.moveTo(w * 0.35, grooveY);
      groovePath.lineTo(w * 0.65, grooveY);
      groovePath.moveTo(w * 0.5, grooveY - (h * 0.08));
      groovePath.lineTo(w * 0.5, grooveY + (h * 0.08));
      canvas.drawPath(groovePath, paint);
    } else if (shape == ToothShape.firstPremolar || shape == ToothShape.secondPremolar) {
      final grooveY = isUpper ? h * 0.82 : h * 0.18;
      final groovePath = Path();
      groovePath.moveTo(w * 0.4, grooveY);
      groovePath.lineTo(w * 0.6, grooveY);
      canvas.drawPath(groovePath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ToothPainter oldDelegate) {
    return oldDelegate.shape != shape ||
        oldDelegate.isUpper != isUpper ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.procedure != procedure ||
        oldDelegate.procedureColor != procedureColor;
  }

  static Path getToothPath(ToothShape shape, Size size, bool isUpper) {
    Path path = _createBaseToothPath(shape, size);

    // Flip vertically for lower jaw teeth so crown points UP (toward horizontal divider)
    if (!isUpper) {
      final Matrix4 matrix = Matrix4.identity()
        ..translate(0.0, size.height)
        ..scale(1.0, -1.0);
      path = path.transform(matrix.storage);
    }

    return path;
  }

  static Path _createBaseToothPath(ToothShape shape, Size size) {
    final w = size.width;
    final h = size.height;
    final Path path = Path();
    
    final rootTip = h * 0.04;
    final cej = h * 0.52;
    final crownEdge = h * 0.96;

    switch (shape) {
      case ToothShape.centralIncisor:
        // Single tapered root, chisel-like crown
        path.moveTo(w * 0.5, rootTip);
        path.cubicTo(w * 0.35, h * 0.2, w * 0.28, h * 0.4, w * 0.22, cej);
        path.cubicTo(w * 0.18, h * 0.7, w * 0.2, crownEdge, w * 0.28, crownEdge);
        path.lineTo(w * 0.72, crownEdge);
        path.cubicTo(w * 0.8, crownEdge, w * 0.82, h * 0.7, w * 0.78, cej);
        path.cubicTo(w * 0.72, h * 0.4, w * 0.65, h * 0.2, w * 0.5, rootTip);
        break;
      
      case ToothShape.lateralIncisor:
        // Slightly curved root tip, rounded distal incisal angle
        path.moveTo(w * 0.53, rootTip);
        path.cubicTo(w * 0.38, h * 0.2, w * 0.3, h * 0.4, w * 0.25, cej);
        path.cubicTo(w * 0.2, h * 0.7, w * 0.24, crownEdge - h * 0.03, w * 0.32, crownEdge - h * 0.03);
        path.lineTo(w * 0.68, crownEdge - h * 0.03);
        path.cubicTo(w * 0.78, crownEdge - h * 0.03, w * 0.8, h * 0.7, w * 0.75, cej);
        path.cubicTo(w * 0.7, h * 0.4, w * 0.68, h * 0.2, w * 0.53, rootTip);
        break;
      
      case ToothShape.canine:
        // Long stout root, prominent pointed cusp
        path.moveTo(w * 0.5, h * 0.01);
        path.cubicTo(w * 0.32, h * 0.2, w * 0.28, h * 0.4, w * 0.24, cej);
        path.cubicTo(w * 0.15, h * 0.7, w * 0.35, crownEdge - h * 0.08, w * 0.5, crownEdge);
        path.cubicTo(w * 0.65, crownEdge - h * 0.08, w * 0.85, h * 0.7, w * 0.76, cej);
        path.cubicTo(w * 0.72, h * 0.4, w * 0.68, h * 0.2, w * 0.5, h * 0.01);
        break;
        
      case ToothShape.firstPremolar:
        // Bifurcated roots (two root tips), two distinct cusps
        path.moveTo(w * 0.38, rootTip);
        path.cubicTo(w * 0.32, h * 0.25, w * 0.28, h * 0.4, w * 0.22, cej);
        path.cubicTo(w * 0.15, h * 0.75, w * 0.28, crownEdge, w * 0.4, crownEdge);
        path.cubicTo(w * 0.48, crownEdge - h * 0.05, w * 0.52, crownEdge - h * 0.05, w * 0.6, crownEdge);
        path.cubicTo(w * 0.72, crownEdge, w * 0.85, h * 0.75, w * 0.78, cej);
        path.cubicTo(w * 0.72, h * 0.4, w * 0.68, h * 0.25, w * 0.62, rootTip);
        // Bifurcation root groove
        path.cubicTo(w * 0.55, h * 0.2, w * 0.52, h * 0.35, w * 0.5, h * 0.42);
        path.cubicTo(w * 0.48, h * 0.35, w * 0.45, h * 0.2, w * 0.38, rootTip);
        break;

      case ToothShape.secondPremolar:
        // Single root, rounded bicuspid crown
        path.moveTo(w * 0.5, rootTip);
        path.cubicTo(w * 0.35, h * 0.25, w * 0.28, h * 0.4, w * 0.24, cej);
        path.cubicTo(w * 0.16, h * 0.75, w * 0.3, crownEdge, w * 0.42, crownEdge);
        path.cubicTo(w * 0.5, crownEdge - h * 0.04, w * 0.52, crownEdge - h * 0.04, w * 0.58, crownEdge);
        path.cubicTo(w * 0.7, crownEdge, w * 0.84, h * 0.75, w * 0.76, cej);
        path.cubicTo(w * 0.72, h * 0.4, w * 0.65, h * 0.25, w * 0.5, rootTip);
        break;

      case ToothShape.firstMolar:
        // Wide multi-rooted molar (3 roots / 4 cusps)
        path.moveTo(w * 0.26, rootTip);
        path.cubicTo(w * 0.2, h * 0.25, w * 0.18, h * 0.4, w * 0.14, cej);
        path.cubicTo(w * 0.05, h * 0.75, w * 0.22, crownEdge, w * 0.34, crownEdge); // Mesial cusp
        path.cubicTo(w * 0.42, crownEdge - h * 0.06, w * 0.46, crownEdge - h * 0.06, w * 0.5, crownEdge); // Center cusp dip
        path.cubicTo(w * 0.54, crownEdge - h * 0.06, w * 0.58, crownEdge - h * 0.06, w * 0.66, crownEdge); // Distal cusp
        path.cubicTo(w * 0.78, crownEdge, w * 0.95, h * 0.75, w * 0.86, cej);
        path.cubicTo(w * 0.82, h * 0.4, w * 0.8, h * 0.25, w * 0.74, rootTip);
        // Root bifurcation 1
        path.cubicTo(w * 0.65, h * 0.22, w * 0.58, h * 0.36, w * 0.55, h * 0.42);
        // Middle palatal root tip
        path.cubicTo(w * 0.52, h * 0.32, w * 0.5, h * 0.2, w * 0.5, rootTip + h * 0.08);
        path.cubicTo(w * 0.5, h * 0.2, w * 0.48, h * 0.32, w * 0.45, h * 0.42);
        // Root bifurcation 2
        path.cubicTo(w * 0.42, h * 0.36, w * 0.35, h * 0.22, w * 0.26, rootTip);
        break;

      case ToothShape.secondMolar:
        // Compact multi-rooted molar (2 main roots)
        path.moveTo(w * 0.3, rootTip + h * 0.04);
        path.cubicTo(w * 0.24, h * 0.25, w * 0.2, h * 0.4, w * 0.16, cej);
        path.cubicTo(w * 0.08, h * 0.75, w * 0.25, crownEdge - h * 0.02, w * 0.38, crownEdge - h * 0.02);
        path.cubicTo(w * 0.46, crownEdge - h * 0.06, w * 0.54, crownEdge - h * 0.06, w * 0.62, crownEdge - h * 0.02);
        path.cubicTo(w * 0.75, crownEdge - h * 0.02, w * 0.92, h * 0.75, w * 0.84, cej);
        path.cubicTo(w * 0.8, h * 0.4, w * 0.76, h * 0.25, w * 0.7, rootTip + h * 0.04);
        path.cubicTo(w * 0.6, h * 0.24, w * 0.54, h * 0.36, w * 0.5, h * 0.44);
        path.cubicTo(w * 0.46, h * 0.36, w * 0.4, h * 0.24, w * 0.3, rootTip + h * 0.04);
        break;

      case ToothShape.thirdMolar:
        // Smallest, fused roots
        path.moveTo(w * 0.36, rootTip + h * 0.08);
        path.cubicTo(w * 0.28, h * 0.28, w * 0.24, h * 0.42, w * 0.2, cej);
        path.cubicTo(w * 0.12, h * 0.75, w * 0.3, crownEdge - h * 0.05, w * 0.42, crownEdge - h * 0.05);
        path.cubicTo(w * 0.5, crownEdge - h * 0.08, w * 0.58, crownEdge - h * 0.05, w * 0.68, crownEdge - h * 0.05);
        path.cubicTo(w * 0.86, h * 0.75, w * 0.8, h * 0.42, w * 0.76, cej);
        path.cubicTo(w * 0.72, h * 0.28, w * 0.64, h * 0.18, w * 0.36, rootTip + h * 0.08);
        break;
    }
    
    path.close();
    return path;
  }
}
