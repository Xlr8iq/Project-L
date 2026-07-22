import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/odontogram_provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/tooth.dart';

class InteractiveJawImage extends StatelessWidget {
  const InteractiveJawImage({Key? key}) : super(key: key);

  static const Map<int, Offset> toothCoordinates = {
    // Upper Jaw
    1: Offset(0.10, 0.3), 2: Offset(0.15, 0.3), 3: Offset(0.20, 0.3),
    4: Offset(0.25, 0.3), 5: Offset(0.30, 0.3), 6: Offset(0.35, 0.3),
    7: Offset(0.40, 0.3), 8: Offset(0.45, 0.3), 9: Offset(0.50, 0.3),
    10: Offset(0.55, 0.3), 11: Offset(0.60, 0.3), 12: Offset(0.65, 0.3),
    13: Offset(0.70, 0.3), 14: Offset(0.75, 0.3), 15: Offset(0.80, 0.3),
    16: Offset(0.85, 0.3),

    // Lower Jaw
    32: Offset(0.10, 0.7), 31: Offset(0.15, 0.7), 30: Offset(0.20, 0.7),
    29: Offset(0.25, 0.7), 28: Offset(0.30, 0.7), 27: Offset(0.35, 0.7),
    26: Offset(0.40, 0.7), 25: Offset(0.45, 0.7), 24: Offset(0.50, 0.7),
    23: Offset(0.55, 0.7), 22: Offset(0.60, 0.7), 21: Offset(0.65, 0.7),
    20: Offset(0.70, 0.7), 19: Offset(0.75, 0.7), 18: Offset(0.80, 0.7),
    17: Offset(0.85, 0.7),
  };

  Color _getColorForProcedure(ProcedureType type) {
    switch (type) {
      case ProcedureType.restoration: return AppTheme.chartRestoration;
      case ProcedureType.extraction: return AppTheme.chartExtraction;
      case ProcedureType.endo: return AppTheme.chartEndo;
      case ProcedureType.implant: return AppTheme.chartImplant;
      case ProcedureType.crown: return AppTheme.chartCrown;
      case ProcedureType.veneer: return AppTheme.chartVeneer;
      case ProcedureType.bridge: return AppTheme.chartBridge;
      case ProcedureType.none:
      default: return Colors.transparent;
    }
  }

  String _getImageForTooth(int toothNumber) {
    if ([7, 8, 9, 10, 23, 24, 25, 26].contains(toothNumber)) return 'assets/images/incisor.png';
    if ([6, 11, 22, 27].contains(toothNumber)) return 'assets/images/canine.png';
    if ([4, 5, 12, 13, 20, 21, 28, 29].contains(toothNumber)) return 'assets/images/premolar.png';
    return 'assets/images/molar.png';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            
            final double hitboxWidth = width * 0.045; 
            final double hitboxHeight = hitboxWidth * 1.5;

            return Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/jaw_base.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
                
                // Cross / Midlines
                Positioned.fill(
                  child: CustomPaint(
                    painter: ChartLinesPainter(),
                  ),
                ),

                // 'R' Indicator (Patient's Right is on the Left side of chart)
                Positioned(
                  left: width * 0.02,
                  top: height * 0.48,
                  child: const Text(
                    'R',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 'L' Indicator (Patient's Left is on the Right side of chart)
                Positioned(
                  right: width * 0.02,
                  top: height * 0.48,
                  child: const Text(
                    'L',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Interactive Tooth Photos
                ...toothCoordinates.entries.map((entry) {
                  final int toothNumber = entry.key;
                  final Offset pos = entry.value;
                  final tooth = provider.getTooth(toothNumber);
                  final isSelected = provider.selectedTooth == toothNumber;
                  final procedureColor = _getColorForProcedure(tooth.procedure);

                  final double leftPos = pos.dx * width - (hitboxWidth / 2);
                  final double topPos = pos.dy * height - (hitboxHeight / 2);

                  final bool isLower = toothNumber >= 17;

                  return Positioned(
                    left: leftPos,
                    top: topPos,
                    child: GestureDetector(
                      onTap: () => provider.selectTooth(toothNumber),
                      child: Container(
                        width: hitboxWidth,
                        height: hitboxHeight,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppTheme.accentCyan : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          color: AppTheme.surfaceDark.withOpacity(0.3),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.rotate(
                              // Upper teeth crowns point down (rotate 180 degrees)
                              // Lower teeth crowns point up (rotate 0 degrees)
                              angle: isLower ? 0 : 3.14159, 
                              child: Image.asset(
                                _getImageForTooth(toothNumber),
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.error, size: 16),
                              ),
                            ),
                            
                            if (tooth.procedure != ProcedureType.none)
                              Container(
                                color: procedureColor.withOpacity(0.5),
                              ),

                            if (isSelected || tooth.procedure == ProcedureType.none)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: Text(
                                    tooth.displayNumber,
                                    style: TextStyle(
                                      color: isSelected ? AppTheme.accentCyan : AppTheme.textSecondary, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}

class ChartLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textSecondary.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Horizontal line exact middle
    canvas.drawLine(
      Offset(size.width * 0.05, size.height * 0.5), 
      Offset(size.width * 0.95, size.height * 0.5), 
      paint
    );

    // Vertical line between teeth 8/9 and 24/25
    // X at 0.475 is exactly between 0.45 and 0.50
    canvas.drawLine(
      Offset(size.width * 0.475, size.height * 0.1), 
      Offset(size.width * 0.475, size.height * 0.9), 
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
