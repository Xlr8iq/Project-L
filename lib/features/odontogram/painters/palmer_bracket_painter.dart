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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;

    // Bracket dimensions
    final bracketWidth = w * 0.6;
    final bracketHeight = h * 0.6;

    // Origin point for the bracket corner based on quadrant
    double cornerX = 0;
    double cornerY = 0;
    
    // Draw lines
    final path = Path();

    switch (quadrant) {
      case 1: // UR: ┘
        cornerX = w;
        cornerY = h;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
      case 2: // UL: └
        cornerX = 0;
        cornerY = h;
        path.moveTo(cornerX, cornerY - bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 3: // LL: ┌
        cornerX = 0;
        cornerY = 0;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX + bracketWidth, cornerY);
        break;
      case 4: // LR: ┐
        cornerX = w;
        cornerY = 0;
        path.moveTo(cornerX, cornerY + bracketHeight);
        path.lineTo(cornerX, cornerY);
        path.lineTo(cornerX - bracketWidth, cornerY);
        break;
    }

    canvas.drawPath(path, paint);

    // Draw Palmer number
    final textStyle = TextStyle(
      color: color,
      fontSize: h * 0.4,
      fontWeight: FontWeight.bold,
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

    // Position text inside the open corner of the bracket
    double textX = 0;
    double textY = 0;

    final paddingX = w * 0.1;
    final paddingY = h * 0.1;

    switch (quadrant) {
      case 1: // UR
        textX = w - textPainter.width - paddingX;
        textY = h - textPainter.height - paddingY;
        break;
      case 2: // UL
        textX = paddingX;
        textY = h - textPainter.height - paddingY;
        break;
      case 3: // LL
        textX = paddingX;
        textY = paddingY;
        break;
      case 4: // LR
        textX = w - textPainter.width - paddingX;
        textY = paddingY;
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
