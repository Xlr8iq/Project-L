import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/tooth.dart';
import '../../../core/theme.dart';
import '../providers/odontogram_provider.dart';

class ClinicalSidebar extends StatelessWidget {
  const ClinicalSidebar({Key? key}) : super(key: key);

  Widget _buildProcedureButton(BuildContext context, String label, Color color, ProcedureType type, OdontogramProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () => provider.applyProcedure(type),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OdontogramProvider>(
      builder: (context, provider, child) {
        if (provider.selectedTooth == null) {
          return const Center(
            child: Text(
              'Select a tooth\nto chart procedures.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
            ),
          );
        }

        final tooth = provider.getTooth(provider.selectedTooth!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tooth #${tooth.displayNumber}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accentCyan),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${tooth.procedure.name.toUpperCase()}',
              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildProcedureButton(context, 'Restoration', AppTheme.chartRestoration, ProcedureType.restoration, provider),
            _buildProcedureButton(context, 'Extraction', AppTheme.chartExtraction, ProcedureType.extraction, provider),
            _buildProcedureButton(context, 'Endodontic', AppTheme.chartEndo, ProcedureType.endo, provider),
            _buildProcedureButton(context, 'Implant', AppTheme.chartImplant, ProcedureType.implant, provider),
            _buildProcedureButton(context, 'Crown', AppTheme.chartCrown, ProcedureType.crown, provider),
            _buildProcedureButton(context, 'Veneer', AppTheme.chartVeneer, ProcedureType.veneer, provider),
            _buildProcedureButton(context, 'Bridge', AppTheme.chartBridge, ProcedureType.bridge, provider),
            const Spacer(),
            TextButton.icon(
              onPressed: () => provider.applyProcedure(ProcedureType.none),
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              label: const Text('Clear Procedure', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
