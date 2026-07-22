import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';
import '../painters/tooth_painter.dart';
import '../painters/palmer_bracket_painter.dart';

class PalmerChart extends StatelessWidget {
  const PalmerChart({Key? key}) : super(key: key);

  // Quadrant tooth order matching reference:
  // Upper Right (Top-Left on screen): Palmer 8,7,6,5,4,3,2,1  → Universal 1,2,3,4,5,6,7,8
  static const List<int> upperRight = [1, 2, 3, 4, 5, 6, 7, 8];
  // Upper Left (Top-Right on screen): Palmer 1,2,3,4,5,6,7,8  → Universal 9,10,11,12,13,14,15,16
  static const List<int> upperLeft = [9, 10, 11, 12, 13, 14, 15, 16];
  // Lower Right (Bottom-Left on screen): Palmer 8,7,6,5,4,3,2,1 → Universal 32,31,30,29,28,27,26,25
  static const List<int> lowerRight = [32, 31, 30, 29, 28, 27, 26, 25];
  // Lower Left (Bottom-Right on screen): Palmer 1,2,3,4,5,6,7,8  → Universal 24,23,22,21,20,19,18,17
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
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chartWidth = constraints.maxWidth;
              final chartHeight = constraints.maxHeight;

              // Calculate spacing and dimensions dynamically
              final toothCellWidth = (chartWidth - 40) / 17; // 16 teeth + 1 center gap
              final toothImageHeight = (chartHeight - 120) / 2.6;
              final bracketHeight = toothCellWidth * 0.75;
              final midlineX = chartWidth / 2;
              final midlineY = chartHeight / 2;

              return Stack(
                children: [
                  // ─── Blue Cross Divider (3dp, #1565C0) ───
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CrossDividerPainter(
                        midlineX: midlineX,
                        midlineY: midlineY,
                      ),
                    ),
                  ),

                  // ─── Quadrants Layout ───
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ─── UPPER ARCH ───
                      Column(
                        children: [
                          // Quadrant Titles (Centered above each upper quadrant)
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Upper Right',
                                    style: TextStyle(
                                      color: AppTheme.chartBlueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Upper Left',
                                    style: TextStyle(
                                      color: AppTheme.chartBlueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Palmer Brackets Row (Upper)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._buildBracketRow(upperRight, provider, bracketHeight, toothCellWidth),
                              SizedBox(width: toothCellWidth), // Center divider gap
                              ..._buildBracketRow(upperLeft, provider, bracketHeight, toothCellWidth),
                            ],
                          ),

                          // Anatomical Teeth Row (Upper)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._buildToothRow(upperRight, provider, toothImageHeight, toothCellWidth),
                              SizedBox(width: toothCellWidth), // Center divider gap
                              ..._buildToothRow(upperLeft, provider, toothImageHeight, toothCellWidth),
                            ],
                          ),
                        ],
                      ),

                      // ─── LOWER ARCH ───
                      Column(
                        children: [
                          // Anatomical Teeth Row (Lower)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._buildToothRow(lowerRight, provider, toothImageHeight, toothCellWidth),
                              SizedBox(width: toothCellWidth), // Center divider gap
                              ..._buildToothRow(lowerLeft, provider, toothImageHeight, toothCellWidth),
                            ],
                          ),

                          // Palmer Brackets Row (Lower)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ..._buildBracketRow(lowerRight, provider, bracketHeight, toothCellWidth),
                              SizedBox(width: toothCellWidth), // Center divider gap
                              ..._buildBracketRow(lowerLeft, provider, bracketHeight, toothCellWidth),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Quadrant Titles (Centered below each lower quadrant)
                          Row(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Lower Right',
                                    style: TextStyle(
                                      color: AppTheme.chartBlueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    'Lower Left',
                                    style: TextStyle(
                                      color: AppTheme.chartBlueAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
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

/// Draws the continuous blue horizontal and vertical cross divider lines (3dp thick, #1565C0)
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

    // Continuous Horizontal Line
    canvas.drawLine(
      Offset(16, midlineY),
      Offset(size.width - 16, midlineY),
      paint,
    );

    // Continuous Vertical Line
    canvas.drawLine(
      Offset(midlineX, 16),
      Offset(midlineX, size.height - 16),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossDividerPainter oldDelegate) {
    return oldDelegate.midlineX != midlineX || oldDelegate.midlineY != midlineY;
  }
}
