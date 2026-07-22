import 'package:flutter/material.dart';

class PalmerBracketPainter extends CustomPainter {
  final int quadrant; // 1=UR, 2=UL, 3=LL, 4=LR
  final int palmerNumber;
  final bool isSelected;
  final double scale;

  PalmerBracketPainter({
    required this.quadrant,
    required this.palmerNumber,
    required this.isSelected,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final color = isSelected ? const Color(0xFF1565C0) : const Color(0xFF263238);
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = isSelected ? 2.5 : 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    // Bracket dimensions (matching reference spacing)
    final bracketWidth = w * 0.45;
    final bracketHeight = h * 0.55;

    double cornerX = 0;
    double cornerY = 0;
    
    final path = Path();

    switch (quadrant) {
      case 1: // UR: ┘ (vertical line on right, horizontal line on bottom)
        cornerX = w * 0.70;
        cornerY = h * 0.85;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
      case 2: // UL: └ (vertical line on left, horizontal line on bottom)
        cornerX = w * 0.30;
        cornerY = h * 0.85;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 3: // LL: ┌ (vertical line on left, horizontal line on top)
        cornerX = w * 0.30;
        cornerY = h * 0.15;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 4: // LR: ┐ (vertical line on right, horizontal line on top)
        cornerX = w * 0.70;
        cornerY = h * 0.15;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
    }

    canvas.drawPath(path, paint);

    // Draw Palmer Number inside open corner of bracket
    final textStyle = TextStyle(
      color: color,
      fontSize: h * 0.48 * scale,
      fontWeight: FontWeight.w700,
    );

    final textSpan = TextSpan(
      text: palmerNumber.toString(),
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    double textX = 0;
    double textY = 0;

    final gap = 3.0 * scale;

    switch (quadrant) {
      case 1: // UR: text to the right of vertical line, above horizontal line
        textX = cornerX + gap;
        textY = cornerY - textPainter.height + (2.0 * scale);
        break;
      case 2: // UL: text to the right of vertical line, above horizontal line
        textX = cornerX + gap + (2.0 * scale);
        textY = cornerY - textPainter.height + (2.0 * scale);
        break;
      case 3: // LL: text to the right of vertical line, below horizontal line
        textX = cornerX + gap + (2.0 * scale);
        textY = cornerY - (2.0 * scale);
        break;
      case 4: // LR: text to the right of vertical line, below horizontal line
        textX = cornerX + gap;
        textY = cornerY - (2.0 * scale);
        break;
    }

    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant PalmerBracketPainter oldDelegate) {
    return oldDelegate.quadrant != quadrant ||
        oldDelegate.palmerNumber != palmerNumber ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.scale != scale;
  }
}
