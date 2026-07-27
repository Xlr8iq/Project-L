import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../dashboard/providers/settings_provider.dart';
import '../providers/odontogram_provider.dart';
import '../painters/palmer_bracket_painter.dart';
import '../painters/surface_diagram_painter.dart';
import '../../treatment_plan/screens/treatment_plan_screen.dart';

class ToothDetailPanel extends StatelessWidget {
  const ToothDetailPanel({Key? key}) : super(key: key);

  Widget _buildProcedureCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required ProcedureType type,
    required Tooth tooth,
    required OdontogramProvider provider,
    required SettingsProvider settings,
  }) {
    final isSelected = tooth.procedure == type;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => provider.assignDraftProcedure(type),
      child: Container(
        width: 86,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(
              settings.translate(label),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppTheme.primaryBlue : const Color(0xFF37474F),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        final toothNumber = provider.selectedTooth ?? 1;
        final tooth = provider.getTooth(toothNumber);
        final hasDraftItems = provider.draftProcedures.isNotEmpty;

        final translatedToothName = '${settings.translate(tooth.quadrantName)} ${settings.translate(tooth.toothTypeName)}';

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Banner if draft diagnosis items are queued
                if (hasDraftItems) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.playlist_add_check, color: AppTheme.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              '${provider.draftProcedures.length} ${settings.translate("Planned Diagnosis Items Queued")}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 13),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: Text(settings.translate('Save Treatment Plan')),
                          onPressed: () async {
                            final clinicProvider = Provider.of<ClinicProvider>(context, listen: false);
                            await provider.saveTreatmentPlan(clinicProvider);

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(settings.translate('Treatment Plan created & saved successfully!')),
                                backgroundColor: Colors.green,
                              ),
                            );

                            if (provider.patientId != null) {
                              final patient = clinicProvider.getPatientById(provider.patientId!);
                              if (patient != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TreatmentPlanScreen(patient: patient),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 750;

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Surface Diagram
                          GestureDetector(
                            onTapDown: (details) {
                              final surface = SurfaceDiagramPainter.hitTestSurface(
                                details.localPosition,
                                const Size(115, 115),
                              );
                              if (surface != null) {
                                provider.toggleSurface(surface);
                              }
                            },
                            child: SizedBox(
                              width: 115,
                              height: 115,
                              child: CustomPaint(
                                painter: SurfaceDiagramPainter(
                                  selectedSurfaces: provider.selectedSurfaces,
                                  isAnterior: tooth.isAnterior,
                                  isUpper: tooth.isUpper,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          // Palmer Bracket & Tooth Info
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 46,
                                      height: 46,
                                      child: CustomPaint(
                                        painter: PalmerBracketPainter(
                                          quadrant: tooth.palmerQuadrant,
                                          palmerNumber: tooth.palmerNumber,
                                          isSelected: true,
                                          scale: 1.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        translatedToothName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    _buildMetadataChip(settings.translate('Quadrant'), settings.translate(tooth.quadrantName)),
                                    const SizedBox(width: 12),
                                    const SizedBox(height: 24, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                                    const SizedBox(width: 12),
                                    _buildMetadataChip(settings.translate('Tooth Type'), settings.translate(tooth.toothTypeName)),
                                    const SizedBox(width: 12),
                                    const SizedBox(height: 24, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                                    const SizedBox(width: 12),
                                    _buildMetadataChip(settings.translate('Dentition'), settings.translate(tooth.dentition)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),
                          const SizedBox(height: 120, child: VerticalDivider(width: 1, color: Color(0xFFE2E8F0))),
                          const SizedBox(width: 16),

                          // Procedure Selection for Diagnosis
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  settings.translate('Assign Procedure to Treatment Plan'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Composite',
                                      icon: Icons.medical_services,
                                      color: AppTheme.primaryBlue,
                                      type: ProcedureType.restoration,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Root Canal',
                                      icon: Icons.healing,
                                      color: Colors.orange.shade700,
                                      type: ProcedureType.endo,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Crown',
                                      icon: Icons.shield,
                                      color: Colors.amber.shade700,
                                      type: ProcedureType.crown,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Extraction',
                                      icon: Icons.remove_circle_outline,
                                      color: Colors.red.shade600,
                                      type: ProcedureType.extraction,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Implant',
                                      icon: Icons.build,
                                      color: Colors.blueGrey.shade700,
                                      type: ProcedureType.implant,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Veneer',
                                      icon: Icons.auto_awesome,
                                      color: Colors.purple.shade600,
                                      type: ProcedureType.veneer,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
                                    _buildProcedureCard(
                                      context: context,
                                      label: 'Clear / None',
                                      icon: Icons.clear,
                                      color: Colors.grey.shade700,
                                      type: ProcedureType.none,
                                      tooth: tooth,
                                      provider: provider,
                                      settings: settings,
                                    ),
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
                              width: 44,
                              height: 44,
                              child: CustomPaint(
                                painter: PalmerBracketPainter(
                                  quadrant: tooth.palmerQuadrant,
                                  palmerNumber: tooth.palmerNumber,
                                  isSelected: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translatedToothName,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                  ),
                                  Text(
                                    '${settings.translate(tooth.quadrantName)} • ${settings.translate(tooth.dentition)}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          settings.translate('Assign Procedure to Treatment Plan'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildProcedureCard(
                              context: context,
                              label: 'Composite',
                              icon: Icons.medical_services,
                              color: AppTheme.primaryBlue,
                              type: ProcedureType.restoration,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                            _buildProcedureCard(
                              context: context,
                              label: 'Root Canal',
                              icon: Icons.healing,
                              color: Colors.orange.shade700,
                              type: ProcedureType.endo,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                            _buildProcedureCard(
                              context: context,
                              label: 'Crown',
                              icon: Icons.shield,
                              color: Colors.amber.shade700,
                              type: ProcedureType.crown,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                            _buildProcedureCard(
                              context: context,
                              label: 'Extraction',
                              icon: Icons.remove_circle_outline,
                              color: Colors.red.shade600,
                              type: ProcedureType.extraction,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                            _buildProcedureCard(
                              context: context,
                              label: 'Implant',
                              icon: Icons.build,
                              color: Colors.blueGrey.shade700,
                              type: ProcedureType.implant,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                            _buildProcedureCard(
                              context: context,
                              label: 'Veneer',
                              icon: Icons.auto_awesome,
                              color: Colors.purple.shade600,
                              type: ProcedureType.veneer,
                              tooth: tooth,
                              provider: provider,
                              settings: settings,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadataChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
