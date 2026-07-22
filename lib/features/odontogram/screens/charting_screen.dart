import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../providers/odontogram_provider.dart';
import '../widgets/palmer_chart.dart';
import '../widgets/tooth_detail_panel.dart';

class ChartingScreen extends StatelessWidget {
  final Patient? patient;
  
  const ChartingScreen({Key? key, this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = OdontogramProvider();
        if (patient != null && patient!.id != null) {
          provider.loadChart(patient!.id!);
        }
        return provider;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Clinical Dental Chart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                patient != null
                    ? 'Palmer Notation • ${patient!.name}'
                    : 'Palmer Notation • Select a tooth',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.crop_free, color: Colors.white),
              onPressed: () {},
              tooltip: 'Fullscreen',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: () {},
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: () {},
              tooltip: 'Zoom Out',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'save') {
                  Navigator.pop(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'save', child: Text('Save & Close')),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // ─── SECTION 1: Palmer Odontogram Chart (~65% Height) ───
            const Expanded(
              flex: 65,
              child: PalmerChart(),
            ),

            // ─── SECTION 2: Clinical Workflow Bottom Card (~35% Height) ───
            const Expanded(
              flex: 35,
              child: ToothDetailPanel(),
            ),
          ],
        ),
      ),
    );
  }
}
