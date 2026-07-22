import 'package:flutter/material.dart';

class PalmerBracketPainter extends CustomPainter {
  final int quadrant; // 1=UR, 2=UL, 3=LL, 4=LR
  final int palmerNumber;
  final bool isSelected;

  PalmerBracketPainter({
    required this.quadrant,
    required this.palmerNumber,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final color = isSelected ? const Color(0xFF1565C0) : const Color(0xFF37474F);
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = isSelected ? 2.2 : 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    // Bracket leg dimensions
    final bracketWidth = w * 0.55;
    final bracketHeight = h * 0.55;

    double cornerX = 0;
    double cornerY = 0;
    
    final path = Path();

    switch (quadrant) {
      case 1: // UR: ┘ (vertical line on right, horizontal line on bottom)
        cornerX = w * 0.85;
        cornerY = h * 0.85;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
      case 2: // UL: └ (vertical line on left, horizontal line on bottom)
        cornerX = w * 0.15;
        cornerY = h * 0.85;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 3: // LL: ┌ (vertical line on left, horizontal line on top)
        cornerX = w * 0.15;
        cornerY = h * 0.15;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 4: // LR: ┐ (vertical line on right, horizontal line on top)
        cornerX = w * 0.85;
        cornerY = h * 0.15;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
    }

    canvas.drawPath(path, paint);

    // Draw Palmer Number inside the open corner
    final textStyle = TextStyle(
      color: color,
      fontSize: h * 0.42,
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter',
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

    const offsetPad = 4.0;

    switch (quadrant) {
      case 1: // UR (Inside corner: left of vertical line, above horizontal line)
        textX = cornerX - textPainter.width - offsetPad;
        textY = cornerY - textPainter.height - offsetPad;
        break;
      case 2: // UL (Inside corner: right of vertical line, above horizontal line)
        textX = cornerX + offsetPad;
        textY = cornerY - textPainter.height - offsetPad;
        break;
      case 3: // LL (Inside corner: right of vertical line, below horizontal line)
        textX = cornerX + offsetPad;
        textY = cornerY + offsetPad;
        break;
      case 4: // LR (Inside corner: left of vertical line, below horizontal line)
        textX = cornerX - textPainter.width - offsetPad;
        textY = cornerY + offsetPad;
        break;
    }

    textPainter.paint(canvas, Offset(textX, textY));
  }

  @override
  bool shouldRepaint(covariant PalmerBracketPainter oldDelegate) {
    return oldDelegate.quadrant != quadrant ||
        oldDelegate.palmerNumber != palmerNumber ||
        oldDelegate.isSelected != isSelected;
  }
}
