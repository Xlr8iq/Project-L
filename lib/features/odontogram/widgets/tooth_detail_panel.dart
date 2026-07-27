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
  }) {
    final isSelected = tooth.procedure == type;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => provider.assignDraftProcedure(type),
      child: Container(
        width: 90,
        height: 56,
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
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(20),
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
          child: Column(
            children: [
              // Banner if draft diagnosis items are queued
              if (hasDraftItems) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
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
                          const Icon(Icons.playlist_add_check, color: AppTheme.primaryBlue),
                          const SizedBox(width: 10),
                          Text(
                            '${provider.draftProcedures.length} ${settings.translate("Planned Diagnosis Items Queued")}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, fontSize: 14),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.save_outlined, size: 18),
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

                          // Open Treatment Plan Roadmap screen
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
                                isUpper: tooth.isUpper,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

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
                                    width: 54,
                                    height: 54,
                                    child: CustomPaint(
                                      painter: PalmerBracketPainter(
                                        quadrant: tooth.palmerQuadrant,
                                        palmerNumber: tooth.palmerNumber,
                                        isSelected: true,
                                        scale: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      tooth.fullName,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  _buildMetadataChip('Quadrant', tooth.quadrantName),
                                  const SizedBox(width: 16),
                                  const SizedBox(height: 28, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                                  const SizedBox(width: 16),
                                  _buildMetadataChip('Tooth Type', tooth.toothTypeName),
                                  const SizedBox(width: 16),
                                  const SizedBox(height: 28, child: VerticalDivider(width: 1, color: Color(0xFFCBD5E1))),
                                  const SizedBox(width: 16),
                                  _buildMetadataChip('Dentition', tooth.dentition),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),
                        const SizedBox(height: 140, child: VerticalDivider(width: 1, color: Color(0xFFE2E8F0))),
                        const SizedBox(width: 20),

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
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Composite',
                                    icon: Icons.medical_services,
                                    color: AppTheme.primaryBlue,
                                    type: ProcedureType.restoration,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Root Canal',
                                    icon: Icons.healing,
                                    color: Colors.orange.shade700,
                                    type: ProcedureType.endo,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Crown',
                                    icon: Icons.shield,
                                    color: Colors.amber.shade700,
                                    type: ProcedureType.crown,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Extraction',
                                    icon: Icons.remove_circle_outline,
                                    color: Colors.red.shade600,
                                    type: ProcedureType.extraction,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Implant',
                                    icon: Icons.build,
                                    color: Colors.blueGrey.shade700,
                                    type: ProcedureType.implant,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Veneer',
                                    icon: Icons.auto_awesome,
                                    color: Colors.purple.shade600,
                                    type: ProcedureType.veneer,
                                    tooth: tooth,
                                    provider: provider,
                                  ),
                                  _buildProcedureCard(
                                    context: context,
                                    label: 'Clear / None',
                                    icon: Icons.clear,
                                    color: Colors.grey.shade700,
                                    type: ProcedureType.none,
                                    tooth: tooth,
                                    provider: provider,
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
                            width: 48,
                            height: 48,
                            child: CustomPaint(
                              painter: PalmerBracketPainter(
                                quadrant: tooth.palmerQuadrant,
                                palmerNumber: tooth.palmerNumber,
                                isSelected: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tooth.fullName,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                      Text(
                        settings.translate('Assign Procedure to Treatment Plan'),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                          ),
                          _buildProcedureCard(
                            context: context,
                            label: 'Root Canal',
                            icon: Icons.healing,
                            color: Colors.orange.shade700,
                            type: ProcedureType.endo,
                            tooth: tooth,
                            provider: provider,
                          ),
                          _buildProcedureCard(
                            context: context,
                            label: 'Crown',
                            icon: Icons.shield,
                            color: Colors.amber.shade700,
                            type: ProcedureType.crown,
                            tooth: tooth,
                            provider: provider,
                          ),
                          _buildProcedureCard(
                            context: context,
                            label: 'Extraction',
                            icon: Icons.remove_circle_outline,
                            color: Colors.red.shade600,
                            type: ProcedureType.extraction,
                            tooth: tooth,
                            provider: provider,
                          ),
                          _buildProcedureCard(
                            context: context,
                            label: 'Implant',
                            icon: Icons.build,
                            color: Colors.blueGrey.shade700,
                            type: ProcedureType.implant,
                            tooth: tooth,
                            provider: provider,
                          ),
                          _buildProcedureCard(
                            context: context,
                            label: 'Veneer',
                            icon: Icons.auto_awesome,
                            color: Colors.purple.shade600,
                            type: ProcedureType.veneer,
                            tooth: tooth,
                            provider: provider,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
