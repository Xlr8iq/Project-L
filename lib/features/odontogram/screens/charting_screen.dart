import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../providers/odontogram_provider.dart';
import '../widgets/interactive_jaw_image.dart';
import '../widgets/clinical_sidebar.dart';

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
        appBar: AppBar(
          title: Text(patient != null ? 'Charting: ${patient!.name}' : 'Clinical Charting'),
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save & Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 800;
            
            if (isDesktop) {
              return Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: InteractiveJawImage(),
                    ),
                  ),
                  Container(width: 1, color: AppTheme.surfaceDark),
                  const Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: ClinicalSidebar(),
                    ),
                  ),
                ],
              );
            }
            
            return Column(
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: InteractiveJawImage(),
                  ),
                ),
                Container(height: 1, color: AppTheme.surfaceDark),
                const Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: ClinicalSidebar(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
