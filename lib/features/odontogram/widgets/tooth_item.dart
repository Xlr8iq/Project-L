import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';

class ToothItem extends StatelessWidget {
  final int toothNumber;
  final bool isUpper;

  const ToothItem({Key? key, required this.toothNumber, this.isUpper = true}) : super(key: key);

  Color _getColorForProcedure(ProcedureType type) {
    switch (type) {
      case ProcedureType.restoration: return AppTheme.chartRestoration;
      case ProcedureType.extraction: return AppTheme.chartExtraction;
      case ProcedureType.endo: return AppTheme.chartEndo;
      case ProcedureType.implant: return AppTheme.chartImplant;
      case ProcedureType.none:
      default: return AppTheme.toothNormal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        final tooth = provider.getTooth(toothNumber);
        final isSelected = provider.selectedTooth == toothNumber;
        final baseColor = _getColorForProcedure(tooth.procedure);

        return GestureDetector(
          onTap: () => provider.selectTooth(toothNumber),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            width: isSelected ? 36 : 28,
            height: isSelected ? 48 : 40,
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.surfaceDark : baseColor,
              borderRadius: BorderRadius.circular(isUpper ? 8.0 : 12.0),
              border: Border.all(
                color: isSelected ? AppTheme.accentCyan : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.5), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isSelected)
                  Text(
                    '$toothNumber',
                    style: TextStyle(
                      color: tooth.procedure == ProcedureType.none ? AppTheme.backgroundDark : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                if (isSelected)
                  Text(
                    '$toothNumber',
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                if (tooth.procedure == ProcedureType.extraction)
                  Positioned.fill(
                    child: CustomPaint(painter: CrossPainter()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(4, 4), Offset(size.width - 4, size.height - 4), paint);
    canvas.drawLine(Offset(size.width - 4, 4), Offset(4, size.height - 4), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
