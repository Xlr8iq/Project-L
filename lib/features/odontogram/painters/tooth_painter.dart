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

    // If there's a procedure, fill the tooth (simulating crown area)
    if (procedure != ProcedureType.none && procedureColor != null) {
      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = procedureColor!.withOpacity(0.3);
      
      // Ideally we'd only fill the crown, but here we fill the path or use a clip
      // Creating a simple clip for the crown area (bottom half for upper, top half for lower)
      canvas.save();
      if (isUpper) {
        canvas.clipRect(Rect.fromLTRB(0, size.height * 0.4, size.width, size.height));
      } else {
        canvas.clipRect(Rect.fromLTRB(0, 0, size.width, size.height * 0.6));
      }
      canvas.drawPath(fullPath, fillPaint);
      canvas.restore();
    }

    final outlineColor = isSelected ? const Color(0xFF1565C0) : const Color(0xFF37474F);
    final outlineWidth = isSelected ? 2.0 : 1.5;

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = outlineColor
      ..strokeWidth = outlineWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fullPath, strokePaint);
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
    // Generate the path with crown at bottom and root at top first.
    Path path = _createBaseToothPath(shape, size);

    // If it's a lower tooth, flip it vertically so the crown is at the top.
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
    
    // Y positions
    final rootTip = h * 0.05;
    final cej = h * 0.55; // Cementoenamel junction
    final crownTip = h * 0.95;

    switch (shape) {
      case ToothShape.centralIncisor:
        // Root
        path.moveTo(w * 0.5, rootTip);
        path.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.2, cej);
        // Crown
        path.quadraticBezierTo(w * 0.15, h * 0.8, w * 0.25, crownTip);
        path.lineTo(w * 0.75, crownTip);
        path.quadraticBezierTo(w * 0.85, h * 0.8, w * 0.8, cej);
        // Root right
        path.quadraticBezierTo(w * 0.75, h * 0.3, w * 0.5, rootTip);
        break;
      
      case ToothShape.lateralIncisor:
        // Slightly narrower
        path.moveTo(w * 0.55, rootTip);
        path.quadraticBezierTo(w * 0.3, h * 0.3, w * 0.25, cej);
        path.quadraticBezierTo(w * 0.2, h * 0.8, w * 0.3, crownTip - h * 0.05);
        path.lineTo(w * 0.7, crownTip - h * 0.05);
        path.quadraticBezierTo(w * 0.8, h * 0.8, w * 0.75, cej);
        path.quadraticBezierTo(w * 0.8, h * 0.3, w * 0.55, rootTip);
        break;
      
      case ToothShape.canine:
        // Pointed crown, long root
        path.moveTo(w * 0.5, h * 0.02); // Longer root
        path.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.25, cej);
        // Crown with point
        path.quadraticBezierTo(w * 0.15, h * 0.7, w * 0.5, crownTip);
        path.quadraticBezierTo(w * 0.85, h * 0.7, w * 0.75, cej);
        path.quadraticBezierTo(w * 0.75, h * 0.3, w * 0.5, h * 0.02);
        break;
        
      case ToothShape.firstPremolar:
        // Bifurcated root, two cusps
        path.moveTo(w * 0.35, rootTip);
        path.quadraticBezierTo(w * 0.3, h * 0.3, w * 0.25, cej);
        path.quadraticBezierTo(w * 0.15, h * 0.8, w * 0.35, crownTip); // buccal cusp
        path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.65, crownTip); // lingual cusp
        path.quadraticBezierTo(w * 0.85, h * 0.8, w * 0.75, cej);
        path.quadraticBezierTo(w * 0.7, h * 0.3, w * 0.65, rootTip);
        path.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.5, h * 0.4); // bifurcation
        path.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.35, rootTip);
        break;

      case ToothShape.secondPremolar:
        // Single root, two cusps
        path.moveTo(w * 0.5, rootTip);
        path.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.25, cej);
        path.quadraticBezierTo(w * 0.15, h * 0.8, w * 0.35, crownTip);
        path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.65, crownTip);
        path.quadraticBezierTo(w * 0.85, h * 0.8, w * 0.75, cej);
        path.quadraticBezierTo(w * 0.75, h * 0.3, w * 0.5, rootTip);
        break;

      case ToothShape.firstMolar:
        // Wide, three roots (approx), 4 cusps
        path.moveTo(w * 0.25, rootTip);
        path.quadraticBezierTo(w * 0.15, h * 0.3, w * 0.15, cej);
        path.quadraticBezierTo(w * 0.05, h * 0.8, w * 0.25, crownTip);
        path.quadraticBezierTo(w * 0.35, h * 0.9, w * 0.45, crownTip);
        path.quadraticBezierTo(w * 0.5, h * 0.85, w * 0.55, crownTip);
        path.quadraticBezierTo(w * 0.65, h * 0.9, w * 0.75, crownTip);
        path.quadraticBezierTo(w * 0.95, h * 0.8, w * 0.85, cej);
        path.quadraticBezierTo(w * 0.85, h * 0.3, w * 0.75, rootTip);
        path.quadraticBezierTo(w * 0.65, h * 0.2, w * 0.6, h * 0.4);
        path.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.5, rootTip + h * 0.1);
        path.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.4, h * 0.4);
        path.quadraticBezierTo(w * 0.35, h * 0.2, w * 0.25, rootTip);
        break;

      case ToothShape.secondMolar:
        // Similar to first molar, slightly smaller and tighter
        path.moveTo(w * 0.3, rootTip + h * 0.05);
        path.quadraticBezierTo(w * 0.2, h * 0.3, w * 0.2, cej);
        path.quadraticBezierTo(w * 0.1, h * 0.8, w * 0.3, crownTip - h * 0.02);
        path.quadraticBezierTo(w * 0.4, h * 0.85, w * 0.5, crownTip - h * 0.02);
        path.quadraticBezierTo(w * 0.6, h * 0.85, w * 0.7, crownTip - h * 0.02);
        path.quadraticBezierTo(w * 0.9, h * 0.8, w * 0.8, cej);
        path.quadraticBezierTo(w * 0.8, h * 0.3, w * 0.7, rootTip + h * 0.05);
        path.quadraticBezierTo(w * 0.6, h * 0.25, w * 0.5, h * 0.4);
        path.quadraticBezierTo(w * 0.4, h * 0.25, w * 0.3, rootTip + h * 0.05);
        break;

      case ToothShape.thirdMolar:
        // Smallest, irregular
        path.moveTo(w * 0.4, rootTip + h * 0.1);
        path.quadraticBezierTo(w * 0.25, h * 0.3, w * 0.25, cej);
        path.quadraticBezierTo(w * 0.15, h * 0.75, w * 0.35, crownTip - h * 0.05);
        path.quadraticBezierTo(w * 0.5, h * 0.8, w * 0.65, crownTip - h * 0.05);
        path.quadraticBezierTo(w * 0.85, h * 0.75, w * 0.75, cej);
        path.quadraticBezierTo(w * 0.75, h * 0.3, w * 0.6, rootTip + h * 0.1);
        path.quadraticBezierTo(w * 0.5, h * 0.3, w * 0.4, rootTip + h * 0.1);
        break;
    }
    
    path.close();
    return path;
  }
}
