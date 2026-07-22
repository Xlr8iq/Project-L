import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';
import '../painters/tooth_painter.dart';
import '../painters/palmer_bracket_painter.dart';

class PalmerChart extends StatelessWidget {
  const PalmerChart({Key? key}) : super(key: key);

  // Universal tooth numbers for each quadrant, ordered LEFT→RIGHT on screen
  // Upper Right: Palmer 8,7,6,5,4,3,2,1  → Universal 1,2,3,4,5,6,7,8
  static const List<int> upperRight = [1, 2, 3, 4, 5, 6, 7, 8];
  // Upper Left: Palmer 1,2,3,4,5,6,7,8  → Universal 9,10,11,12,13,14,15,16
  static const List<int> upperLeft = [9, 10, 11, 12, 13, 14, 15, 16];
  // Lower Right: Palmer 8,7,6,5,4,3,2,1 → Universal 32,31,30,29,28,27,26,25
  static const List<int> lowerRight = [32, 31, 30, 29, 28, 27, 26, 25];
  // Lower Left: Palmer 1,2,3,4,5,6,7,8  → Universal 24,23,22,21,20,19,18,17
  static const List<int> lowerLeft = [24, 23, 22, 21, 20, 19, 18, 17];

  Color _getProcedureColor(ProcedureType type) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final chartWidth = constraints.maxWidth * 0.92;
            final toothCellWidth = chartWidth / 17; // 16 teeth + 1 divider gap
            final toothImageHeight = toothCellWidth * 1.85;
            final bracketHeight = toothCellWidth * 0.75;
            final totalChartHeight = (bracketHeight * 2) + (toothImageHeight * 2) + 76;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: chartWidth,
                  height: totalChartHeight,
                  child: Stack(
                    children: [
                      // ─── Background Cross Divider (Horizontal + Vertical) ───
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _CrossDividerPainter(
                            midlineX: (toothCellWidth * 8) + (toothCellWidth / 2),
                            midlineY: bracketHeight + toothImageHeight + 20,
                          ),
                        ),
                      ),

                      // ─── Chart Content ───
                      Column(
                        children: [
                          // Quadrant Labels (Upper)
                          SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Upper Right',
                                      style: TextStyle(
                                        color: AppTheme.chartBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: toothCellWidth), // center divider gap
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Upper Left',
                                      style: TextStyle(
                                        color: AppTheme.chartBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Upper Row: Brackets + Numbers
                          SizedBox(
                            height: bracketHeight,
                            child: Row(
                              children: [
                                ..._buildBracketRow(upperRight, provider, bracketHeight, toothCellWidth),
                                SizedBox(width: toothCellWidth),
                                ..._buildBracketRow(upperLeft, provider, bracketHeight, toothCellWidth),
                              ],
                            ),
                          ),

                          // Upper Row: Tooth Images
                          SizedBox(
                            height: toothImageHeight,
                            child: Row(
                              children: [
                                ..._buildToothRow(upperRight, provider, toothImageHeight, toothCellWidth),
                                SizedBox(width: toothCellWidth),
                                ..._buildToothRow(upperLeft, provider, toothImageHeight, toothCellWidth),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16), // Divider gap

                          // Lower Row: Tooth Images
                          SizedBox(
                            height: toothImageHeight,
                            child: Row(
                              children: [
                                ..._buildToothRow(lowerRight, provider, toothImageHeight, toothCellWidth),
                                SizedBox(width: toothCellWidth),
                                ..._buildToothRow(lowerLeft, provider, toothImageHeight, toothCellWidth),
                              ],
                            ),
                          ),

                          // Lower Row: Brackets + Numbers
                          SizedBox(
                            height: bracketHeight,
                            child: Row(
                              children: [
                                ..._buildBracketRow(lowerRight, provider, bracketHeight, toothCellWidth),
                                SizedBox(width: toothCellWidth),
                                ..._buildBracketRow(lowerLeft, provider, bracketHeight, toothCellWidth),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Quadrant Labels (Lower)
                          SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Lower Right',
                                      style: TextStyle(
                                        color: AppTheme.chartBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: toothCellWidth),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      'Lower Left',
                                      style: TextStyle(
                                        color: AppTheme.chartBlueAccent,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildBracketRow(
    List<int> toothNumbers,
    OdontogramProvider provider,
    double height,
    double width,
  ) {
    return toothNumbers.map((toothNumber) {
      final tooth = provider.getTooth(toothNumber);
      final isSelected = provider.selectedTooth == toothNumber;
      return SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: PalmerBracketPainter(
            quadrant: tooth.palmerQuadrant,
            palmerNumber: tooth.palmerNumber,
            isSelected: isSelected,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildToothRow(
    List<int> toothNumbers,
    OdontogramProvider provider,
    double height,
    double width,
  ) {
    return toothNumbers.map((toothNumber) {
      final tooth = provider.getTooth(toothNumber);
      final isSelected = provider.selectedTooth == toothNumber;
      final procColor = _getProcedureColor(tooth.procedure);

      return GestureDetector(
        onTap: () => provider.selectTooth(toothNumber),
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: ToothPainter(
              shape: tooth.shape,
              isUpper: tooth.isUpper,
              isSelected: isSelected,
              procedure: tooth.procedure,
              procedureColor: tooth.procedure != ProcedureType.none ? procColor : null,
            ),
          ),
        ),
      );
    }).toList();
  }
}

/// Draws the continuous blue horizontal and vertical cross divider lines (3dp thick)
class _CrossDividerPainter extends CustomPainter {
  final double midlineX;
  final double midlineY;

  _CrossDividerPainter({
    required this.midlineX,
    required this.midlineY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.chartBlueAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    // Continuous Horizontal Divider Line
    canvas.drawLine(
      Offset(0, midlineY),
      Offset(size.width, midlineY),
      paint,
    );

    // Continuous Vertical Divider Line
    canvas.drawLine(
      Offset(midlineX, 20),
      Offset(midlineX, size.height - 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossDividerPainter oldDelegate) {
    return oldDelegate.midlineX != midlineX || oldDelegate.midlineY != midlineY;
  }
}
