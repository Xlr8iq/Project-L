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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppTheme.chartBlueAccent,
          foregroundColor: Colors.white,
          elevation: 2,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient != null ? 'Clinical Dental Chart' : 'Clinical Dental Chart',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
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
              icon: const Icon(Icons.fullscreen, color: Colors.white),
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
          ],
        ),
        body: Column(
          children: [
            // ─── Main Chart Area ───
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: const PalmerChart(),
                ),
              ),
            ),

            // ─── Tooth Detail Panel (bottom) ───
            const ToothDetailPanel(),
          ],
        ),
      ),
    );
  }
}
