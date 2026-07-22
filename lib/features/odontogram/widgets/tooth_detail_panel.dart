import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';
import '../painters/palmer_bracket_painter.dart';
import '../painters/surface_diagram_painter.dart';

class ToothDetailPanel extends StatelessWidget {
  const ToothDetailPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        if (provider.selectedTooth == null) {
          return const SizedBox.shrink();
        }

        final tooth = provider.getTooth(provider.selectedTooth!);

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Palmer bracket + number
                    _buildPalmerDisplay(tooth),
                    const SizedBox(width: 24),
                    // Tooth info
                    Expanded(child: _buildToothInfo(tooth)),
                    // Surface diagram
                    _buildSurfaceDiagram(context, tooth, provider),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildPalmerDisplay(tooth),
                      const SizedBox(width: 24),
                      Expanded(child: _buildToothInfo(tooth)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(child: _buildSurfaceDiagram(context, tooth, provider)),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPalmerDisplay(Tooth tooth) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: PalmerBracketPainter(
          quadrant: tooth.palmerQuadrant,
          palmerNumber: tooth.palmerNumber,
          isSelected: true,
        ),
      ),
    );
  }

  Widget _buildToothInfo(Tooth tooth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tooth.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildInfoChip('Quadrant', tooth.quadrantName),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildInfoChip('Tooth Type', tooth.toothTypeName),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            _buildInfoChip('Dentition', tooth.dentition),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppTheme.chartBlueAccent,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF424242),
          ),
        ),
      ],
    );
  }

  Widget _buildSurfaceDiagram(BuildContext context, Tooth tooth, OdontogramProvider provider) {
    return GestureDetector(
      onTapDown: (details) {
        final surface = SurfaceDiagramPainter.hitTestSurface(
          details.localPosition,
          const Size(160, 160),
        );
        if (surface != null) {
          provider.toggleSurface(surface);
        }
      },
      child: SizedBox(
        width: 160,
        height: 160,
        child: CustomPaint(
          painter: SurfaceDiagramPainter(
            selectedSurfaces: provider.selectedSurfaces,
            isAnterior: tooth.isAnterior,
          ),
        ),
      ),
    );
  }
}
