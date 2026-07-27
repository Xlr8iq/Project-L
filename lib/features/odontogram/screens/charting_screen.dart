import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../providers/odontogram_provider.dart';
import '../widgets/palmer_chart.dart';
import '../widgets/tooth_detail_panel.dart';
import '../../treatment_plan/dialogs/procedure_execution_dialog.dart';
import '../../dashboard/providers/settings_provider.dart';

class ChartingScreen extends StatefulWidget {
  final Patient? patient;
  final int? targetToothNumber;
  final TreatmentPlanItem? targetTreatmentItem;

  const ChartingScreen({
    Key? key,
    this.patient,
    this.targetToothNumber,
    this.targetTreatmentItem,
  }) : super(key: key);

  @override
  State<ChartingScreen> createState() => _ChartingScreenState();
}

class _ChartingScreenState extends State<ChartingScreen> {
  late OdontogramProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = OdontogramProvider();
    if (widget.patient != null && widget.patient!.id != null) {
      _provider.loadChart(widget.patient!.id!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.targetToothNumber != null) {
        _provider.selectTooth(widget.targetToothNumber!);
      }

      if (widget.patient != null && widget.targetTreatmentItem != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ProcedureExecutionDialog(
            patient: widget.patient!,
            item: widget.targetTreatmentItem!,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return ChangeNotifierProvider.value(
      value: _provider,
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
              Text(
                settings.translate('Clinical Dental Chart'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.patient != null
                    ? '${settings.translate("Palmer Notation •")} ${widget.patient!.name}'
                    : settings.translate('Palmer Notation • Select a tooth'),
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
              tooltip: settings.translate('Fullscreen'),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_in, color: Colors.white),
              onPressed: () {},
              tooltip: settings.translate('Zoom In'),
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out, color: Colors.white),
              onPressed: () {},
              tooltip: settings.translate('Zoom Out'),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'save') {
                  Navigator.pop(context);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'save', child: Text(settings.translate('Save & Return to Treatment Plan'))),
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
