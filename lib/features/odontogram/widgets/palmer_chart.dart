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
            // Calculate tooth cell size based on available width
            // 16 teeth + divider across the width, occupying ~80%
            final chartWidth = constraints.maxWidth * 0.92;
            final toothCellWidth = chartWidth / 17; // 16 teeth + 1 divider gap
            final toothImageHeight = toothCellWidth * 1.8;
            final bracketHeight = toothCellWidth * 0.7;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // ─── Quadrant Labels (Upper) ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Upper Right',
                              style: TextStyle(
                                color: AppTheme.chartBlueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: toothCellWidth), // gap for divider
                        Expanded(
                          child: Center(
                            child: Text(
                              'Upper Left',
                              style: TextStyle(
                                color: AppTheme.chartBlueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Upper Row: Brackets + Numbers ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        // Upper Right brackets (Q1)
                        ..._buildBracketRow(upperRight, provider, bracketHeight, toothCellWidth),
                        SizedBox(width: toothCellWidth), // divider gap
                        // Upper Left brackets (Q2)
                        ..._buildBracketRow(upperLeft, provider, bracketHeight, toothCellWidth),
                      ],
                    ),
                  ),

                  // ─── Upper Row: Tooth Images ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        ..._buildToothRow(upperRight, provider, toothImageHeight, toothCellWidth),
                        SizedBox(width: toothCellWidth),
                        ..._buildToothRow(upperLeft, provider, toothImageHeight, toothCellWidth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ─── Blue Divider Lines ───
                  SizedBox(
                    width: chartWidth,
                    height: 3,
                    child: CustomPaint(
                      painter: _DividerPainter(
                        dividerX: chartWidth / 2,
                        aboveHeight: toothImageHeight + bracketHeight + 30,
                        belowHeight: toothImageHeight + bracketHeight + 30,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ─── Lower Row: Tooth Images ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        ..._buildToothRow(lowerRight, provider, toothImageHeight, toothCellWidth),
                        SizedBox(width: toothCellWidth),
                        ..._buildToothRow(lowerLeft, provider, toothImageHeight, toothCellWidth),
                      ],
                    ),
                  ),

                  // ─── Lower Row: Brackets + Numbers ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        ..._buildBracketRow(lowerRight, provider, bracketHeight, toothCellWidth),
                        SizedBox(width: toothCellWidth),
                        ..._buildBracketRow(lowerLeft, provider, bracketHeight, toothCellWidth),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ─── Quadrant Labels (Lower) ───
                  SizedBox(
                    width: chartWidth,
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Lower Right',
                              style: TextStyle(
                                color: AppTheme.chartBlueAccent,
                                fontWeight: FontWeight.w600,
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
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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

/// Draws the horizontal blue divider line across the full width
class _DividerPainter extends CustomPainter {
  final double dividerX;
  final double aboveHeight;
  final double belowHeight;

  _DividerPainter({
    required this.dividerX,
    required this.aboveHeight,
    required this.belowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.chartBlueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Horizontal line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DividerPainter oldDelegate) => false;
}
