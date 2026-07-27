import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/tooth.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../dashboard/providers/settings_provider.dart';

class ProcedureExecutionDialog extends StatefulWidget {
  final Patient patient;
  final TreatmentPlanItem item;

  const ProcedureExecutionDialog({
    Key? key,
    required this.patient,
    required this.item,
  }) : super(key: key);

  @override
  State<ProcedureExecutionDialog> createState() => _ProcedureExecutionDialogState();
}

class _ProcedureExecutionDialogState extends State<ProcedureExecutionDialog> {
  late int _currentVisit;
  late int _totalVisits;
  late TreatmentPlanStatus _status;
  late double _estimatedFee;
  late double _paidAmount;
  late TextEditingController _notesController;
  late String _doctorName;
  DateTime? _nextVisitDate;

  @override
  void initState() {
    super.initState();
    _currentVisit = widget.item.currentVisit;
    _totalVisits = widget.item.totalVisits;
    _status = widget.item.status == TreatmentPlanStatus.planned ? TreatmentPlanStatus.inProgress : widget.item.status;
    _estimatedFee = widget.item.estimatedFee;
    _paidAmount = widget.item.paidAmount;
    _notesController = TextEditingController(text: widget.item.notes);
    _doctorName = widget.item.doctorName;
    _nextVisitDate = widget.item.nextVisitDate;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickNextVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextVisitDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _nextVisitDate = picked);
    }
  }

  void _saveProgress({bool markCompleted = false}) async {
    final provider = Provider.of<ClinicProvider>(context, listen: false);

    TreatmentPlanStatus newStatus = markCompleted
        ? TreatmentPlanStatus.completed
        : (_status == TreatmentPlanStatus.completed ? TreatmentPlanStatus.completed : _status);

    int nextVisit = _currentVisit;
    if (!markCompleted && _currentVisit < _totalVisits) {
      nextVisit = _currentVisit + 1;
    }

    final updated = widget.item.copyWith(
      currentVisit: nextVisit,
      totalVisits: _totalVisits,
      status: newStatus,
      estimatedFee: _estimatedFee,
      paidAmount: _paidAmount,
      doctorName: _doctorName,
      notes: _notesController.text.trim(),
      nextVisitDate: _nextVisitDate,
      completedAt: markCompleted ? DateTime.now() : widget.item.completedAt,
    );

    await provider.updateTreatmentPlanItem(updated);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final provider = context.watch<ClinicProvider>();
    final doctorList = provider.doctors.map((d) => d.name).toList();

    if (doctorList.isNotEmpty && (_doctorName.isEmpty || !doctorList.contains(_doctorName))) {
      _doctorName = doctorList.first;
    }

    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(widget.item.statusIcon, color: widget.item.statusColor, size: 24),
              const SizedBox(width: 10),
              Text(
                widget.item.procedureName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${settings.translate("Tooth")}: ${widget.item.palmerDisplay}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 520,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1, color: AppTheme.borderLight),
              const SizedBox(height: 16),

              // Multi-Visit Counter Bar
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: settings.translate('Current Visit Step'),
                        prefixIcon: const Icon(Icons.pin_drop_outlined),
                      ),
                      value: _currentVisit,
                      items: List.generate(_totalVisits, (i) => i + 1)
                          .map((v) => DropdownMenuItem(value: v, child: Text('${settings.translate("Visit")} $v')))
                          .toList(),
                      onChanged: (v) => setState(() => _currentVisit = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: settings.translate('Total Planned Visits'),
                        prefixIcon: const Icon(Icons.repeat),
                      ),
                      value: _totalVisits,
                      items: [1, 2, 3, 4, 5, 6]
                          .map((v) => DropdownMenuItem(value: v, child: Text('$v ${settings.translate("Visits")}')))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _totalVisits = v!;
                          if (_currentVisit > _totalVisits) _currentVisit = _totalVisits;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Treatment Status Selector
              DropdownButtonFormField<TreatmentPlanStatus>(
                decoration: InputDecoration(
                  labelText: settings.translate('Treatment Status'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                value: _status,
                items: TreatmentPlanStatus.values.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Row(
                      children: [
                        Icon(TreatmentPlanItem(patientId: 0, toothNumber: 1, procedureType: ProcedureType.none, status: s).statusIcon, size: 16, color: TreatmentPlanItem(patientId: 0, toothNumber: 1, procedureType: ProcedureType.none, status: s).statusColor),
                        const SizedBox(width: 8),
                        Text(settings.translate(TreatmentPlanItem(patientId: 0, toothNumber: 1, procedureType: ProcedureType.none, status: s).statusDisplay)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),

              const SizedBox(height: 16),

              // Work Performed / Clinical Notes Today
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: settings.translate('Today\'s Clinical Work & Notes'),
                  hintText: 'e.g. Access cavity prepared, canal cleaned, temporary dressing applied.',
                  prefixIcon: const Icon(Icons.edit_note),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Doctor & Next Visit Date
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: settings.translate('Assigned Doctor'),
                        prefixIcon: const Icon(Icons.medical_services_outlined),
                      ),
                      value: _doctorName.isNotEmpty && doctorList.contains(_doctorName) ? _doctorName : (doctorList.isNotEmpty ? doctorList.first : null),
                      items: doctorList
                          .map((doc) => DropdownMenuItem(value: doc, child: Text(doc)))
                          .toList(),
                      onChanged: (val) => setState(() => _doctorName = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickNextVisitDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: settings.translate('Next Visit Date (Auto-Schedules)'),
                          prefixIcon: const Icon(Icons.event),
                        ),
                        child: Text(
                          _nextVisitDate == null
                              ? settings.translate('Not Scheduled')
                              : DateFormat('MMM dd, yyyy').format(_nextVisitDate!),
                          style: TextStyle(
                            color: _nextVisitDate == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Fee & Payment Today
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _estimatedFee.toStringAsFixed(0),
                      decoration: InputDecoration(
                        labelText: settings.translate('Estimated Fee (\$)'),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() => _estimatedFee = double.tryParse(v) ?? 0.0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _paidAmount.toStringAsFixed(0),
                      decoration: InputDecoration(
                        labelText: settings.translate('Paid Amount (\$)'),
                        prefixIcon: const Icon(Icons.price_check),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() => _paidAmount = double.tryParse(v) ?? 0.0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(settings.translate('Cancel')),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(settings.translate('Save Visit Progress')),
          onPressed: () => _saveProgress(markCompleted: false),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.check_circle, size: 18),
          label: Text(settings.translate('Mark Completed ✓')),
          onPressed: () => _saveProgress(markCompleted: true),
        ),
      ],
    );
  }
}
