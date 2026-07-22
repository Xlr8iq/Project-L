import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';
import '../painters/palmer_bracket_painter.dart';
import '../painters/surface_diagram_painter.dart';

class ToothDetailPanel extends StatelessWidget {
  const ToothDetailPanel({Key? key}) : super(key: key);

  Widget _buildProcedureChip(
    BuildContext context,
    String label,
    Color color,
    ProcedureType type,
    Tooth currentTooth,
    OdontogramProvider provider,
  ) {
    final isCurrent = currentTooth.procedure == type;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => provider.applyProcedure(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? color : color.withOpacity(0.4),
            width: isCurrent ? 2 : 1,
          ),
          boxShadow: isCurrent
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, spreadRadius: 1)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCurrent ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isCurrent ? Colors.white : color.withOpacity(0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        if (provider.selectedTooth == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.touch_app, color: AppTheme.primaryBlue, size: 22),
                SizedBox(width: 10),
                Text(
                  'Select a tooth from the chart above to begin clinical procedure charting',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final tooth = provider.getTooth(provider.selectedTooth!);

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.borderLight, width: 1.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;

              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Column 1: Tooth Identity & Palmer Display ───
                    SizedBox(
                      width: 220,
                      child: Row(
                        children: [
                          // Palmer Display
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: CustomPaint(
                              painter: PalmerBracketPainter(
                                quadrant: tooth.palmerQuadrant,
                                palmerNumber: tooth.palmerNumber,
                                isSelected: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tooth.fullName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${tooth.quadrantName} • ${tooth.dentition}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const VerticalDivider(width: 32, color: AppTheme.borderLight),

                    // ─── Column 2: Surface Diagram Selector ───
                    SizedBox(
                      width: 160,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Surfaces (${provider.selectedSurfaces.length})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTapDown: (details) {
                              final surface = SurfaceDiagramPainter.hitTestSurface(
                                details.localPosition,
                                const Size(130, 130),
                              );
                              if (surface != null) {
                                provider.toggleSurface(surface);
                              }
                            },
                            child: SizedBox(
                              width: 130,
                              height: 130,
                              child: CustomPaint(
                                painter: SurfaceDiagramPainter(
                                  selectedSurfaces: provider.selectedSurfaces,
                                  isAnterior: tooth.isAnterior,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const VerticalDivider(width: 32, color: AppTheme.borderLight),

                    // ─── Column 3 (PRIMARY FOCUS): Procedure Selection Palette ───
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'CLINICAL PROCEDURE SELECTION',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (tooth.procedure != ProcedureType.none)
                                TextButton.icon(
                                  onPressed: () => provider.applyProcedure(ProcedureType.none),
                                  icon: const Icon(Icons.clear, size: 16, color: Colors.redAccent),
                                  label: const Text('Clear Procedure', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildProcedureChip(context, 'Restoration (Composite)', AppTheme.chartRestoration, ProcedureType.restoration, tooth, provider),
                              _buildProcedureChip(context, 'Extraction', AppTheme.chartExtraction, ProcedureType.extraction, tooth, provider),
                              _buildProcedureChip(context, 'Endodontic (RCT)', AppTheme.chartEndo, ProcedureType.endo, tooth, provider),
                              _buildProcedureChip(context, 'Implant', AppTheme.chartImplant, ProcedureType.implant, tooth, provider),
                              _buildProcedureChip(context, 'Crown', AppTheme.chartCrown, ProcedureType.crown, tooth, provider),
                              _buildProcedureChip(context, 'Veneer', AppTheme.chartVeneer, ProcedureType.veneer, tooth, provider),
                              _buildProcedureChip(context, 'Bridge', AppTheme.chartBridge, ProcedureType.bridge, tooth, provider),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Mobile Layout
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: CustomPaint(
                          painter: PalmerBracketPainter(
                            quadrant: tooth.palmerQuadrant,
                            palmerNumber: tooth.palmerNumber,
                            isSelected: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tooth.fullName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            Text(
                              '${tooth.quadrantName} • ${tooth.dentition}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'CLINICAL PROCEDURE SELECTION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildProcedureChip(context, 'Restoration', AppTheme.chartRestoration, ProcedureType.restoration, tooth, provider),
                      _buildProcedureChip(context, 'Extraction', AppTheme.chartExtraction, ProcedureType.extraction, tooth, provider),
                      _buildProcedureChip(context, 'Endodontic', AppTheme.chartEndo, ProcedureType.endo, tooth, provider),
                      _buildProcedureChip(context, 'Implant', AppTheme.chartImplant, ProcedureType.implant, tooth, provider),
                      _buildProcedureChip(context, 'Crown', AppTheme.chartCrown, ProcedureType.crown, tooth, provider),
                      _buildProcedureChip(context, 'Veneer', AppTheme.chartVeneer, ProcedureType.veneer, tooth, provider),
                      _buildProcedureChip(context, 'Bridge', AppTheme.chartBridge, ProcedureType.bridge, tooth, provider),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTapDown: (details) {
                        final surface = SurfaceDiagramPainter.hitTestSurface(
                          details.localPosition,
                          const Size(130, 130),
                        );
                        if (surface != null) {
                          provider.toggleSurface(surface);
                        }
                      },
                      child: SizedBox(
                        width: 130,
                        height: 130,
                        child: CustomPaint(
                          painter: SurfaceDiagramPainter(
                            selectedSurfaces: provider.selectedSurfaces,
                            isAnterior: tooth.isAnterior,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
