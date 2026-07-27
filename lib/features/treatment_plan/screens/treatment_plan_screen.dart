import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../dashboard/providers/settings_provider.dart';
import '../../odontogram/screens/charting_screen.dart';

class TreatmentPlanScreen extends StatefulWidget {
  final Patient patient;
  final bool isReadOnly;

  const TreatmentPlanScreen({
    Key? key,
    required this.patient,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<TreatmentPlanScreen> createState() => _TreatmentPlanScreenState();
}

class _TreatmentPlanScreenState extends State<TreatmentPlanScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClinicProvider>(context, listen: false).loadTreatmentPlan(widget.patient.id!);
    });
  }

  List<TreatmentPlanItem> _filterItems(List<TreatmentPlanItem> items) {
    if (_selectedFilter == 'All') return items;
    if (_selectedFilter == 'Planned') {
      return items.where((i) => i.status == TreatmentPlanStatus.planned || i.status == TreatmentPlanStatus.scheduled).toList();
    }
    if (_selectedFilter == 'In Progress') {
      return items.where((i) => i.status == TreatmentPlanStatus.inProgress || i.status == TreatmentPlanStatus.waitingForLab).toList();
    }
    if (_selectedFilter == 'Completed') {
      return items.where((i) => i.status == TreatmentPlanStatus.completed).toList();
    }
    return items;
  }

  void _openProcedureChart(BuildContext context, TreatmentPlanItem item) {
    final clinicProvider = Provider.of<ClinicProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChartingScreen(
          patient: widget.patient,
          targetToothNumber: item.toothNumber,
          targetTreatmentItem: item,
        ),
      ),
    ).then((_) {
      if (mounted) {
        clinicProvider.loadTreatmentPlan(widget.patient.id!);
      }
    });
  }

  void _confirmDeleteItem(BuildContext context, TreatmentPlanItem item) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(settings.translate('Delete Procedure')),
        content: Text('${settings.translate("Are you sure you want to remove")} ${settings.translate(item.procedureName)} (${item.palmerCode}) ${settings.translate("from treatment plan?")}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ClinicProvider>(context, listen: false).deleteTreatmentPlanItem(widget.patient.id!, item.id!);
            },
            child: Text(settings.translate('Delete')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${settings.translate("Treatment Plan")}: ${widget.patient.name}'),
        actions: [
          if (!widget.isReadOnly)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryBlue,
                  elevation: 1,
                ),
                icon: const Icon(Icons.add_chart),
                label: Text(settings.translate('+ Diagnose / Open Chart')),
                onPressed: () {
                  final clinicProvider = Provider.of<ClinicProvider>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChartingScreen(patient: widget.patient),
                    ),
                  ).then((_) {
                    if (mounted) {
                      clinicProvider.loadTreatmentPlan(widget.patient.id!);
                    }
                  });
                },
              ),
            ),
        ],
      ),
      body: Consumer<ClinicProvider>(
        builder: (context, provider, child) {
          final allItems = provider.getTreatmentPlan(widget.patient.id!);
          final filteredItems = _filterItems(allItems);

          final plannedCount = allItems.where((i) => i.status == TreatmentPlanStatus.planned || i.status == TreatmentPlanStatus.scheduled).length;
          final inProgressCount = allItems.where((i) => i.status == TreatmentPlanStatus.inProgress || i.status == TreatmentPlanStatus.waitingForLab).length;
          final completedCount = allItems.where((i) => i.status == TreatmentPlanStatus.completed).length;
          final totalRem = allItems.fold<double>(0.0, (sum, i) => sum + i.remainingBalance);

          return Column(
            children: [
              // ─── Top Patient & Summary Bar ───
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                          child: const Icon(Icons.person, color: AppTheme.primaryBlue, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.patient.name,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${settings.translate("ID")}: #${widget.patient.id.toString().padLeft(4, '0')} • ${widget.patient.age} ${settings.translate("Age")} • ${settings.translate(widget.patient.gender)}',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),

                        // Stats Badges
                        _buildStatBadge(settings.translate('Planned'), '$plannedCount', const Color(0xFF1565C0)),
                        const SizedBox(width: 12),
                        _buildStatBadge(settings.translate('In Progress'), '$inProgressCount', const Color(0xFFF57C00)),
                        const SizedBox(width: 12),
                        _buildStatBadge(settings.translate('Completed'), '$completedCount', const Color(0xFF2E7D32)),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: totalRem > 0 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: totalRem > 0 ? Colors.orange.shade400 : Colors.green.shade400),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                settings.translate('Remaining Est. Balance'),
                                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                settings.formatCurrency(totalRem),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: totalRem > 0 ? Colors.orange.shade900 : Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filter Tabs Ribbon
                    Row(
                      children: ['All', 'Planned', 'In Progress', 'Completed'].map((tab) {
                        final isSelected = _selectedFilter == tab;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(settings.translate(tab)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedFilter = tab);
                            },
                            selectedColor: AppTheme.primaryBlue,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppTheme.borderLight),

              // ─── Treatment Cards List ───
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_outlined, size: 64, color: AppTheme.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              settings.translate('No treatment plan items found.'),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settings.translate('Click "+ Diagnose / Open Chart" to add teeth procedures to the plan.'),
                              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return _buildTreatmentCard(context, item, settings);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBadge(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTreatmentCard(BuildContext context, TreatmentPlanItem item, SettingsProvider settings) {
    final isDone = item.status == TreatmentPlanStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDone ? Colors.green.shade200 : AppTheme.borderLight,
          width: isDone ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openProcedureChart(context, item),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: item.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.statusIcon, color: item.statusColor, size: 28),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          settings.translate(item.procedureName),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                          ),
                          child: Text(
                            '${settings.translate("Tooth")}: ${item.palmerDisplay}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                          ),
                        ),
                        if (item.totalVisits > 1) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.purple.withOpacity(0.3)),
                            ),
                            child: Text(
                              '${settings.translate("Visit")} ${item.currentVisit} ${settings.translate("Visits")} ${item.totalVisits}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.purple),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(item.statusIcon, size: 14, color: item.statusColor),
                              const SizedBox(width: 6),
                              Text(
                                settings.translate(item.statusDisplay),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: item.statusColor),
                              ),
                            ],
                          ),
                        ),
                        if (item.nextVisitDate != null && !isDone) ...[
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${settings.translate("Next Visit")}: ${settings.formatDateShort(item.nextVisitDate!)}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${settings.translate("Notes:")} ${item.notes}',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    settings.formatCurrency(item.estimatedFee),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  if (item.remainingBalance > 0)
                    Text(
                      '${settings.translate("Remaining Balance:")} ${settings.formatCurrency(item.remainingBalance)}',
                      style: TextStyle(fontSize: 12, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
                    )
                  else
                    Text(
                      settings.translate('Paid in Full'),
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                    ),
                  const SizedBox(height: 12),

                  if (!widget.isReadOnly) ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDone ? Colors.green.shade700 : AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      icon: Icon(isDone ? Icons.check_circle : Icons.play_arrow, size: 16),
                      label: Text(
                        isDone ? settings.translate('View Details') : (item.totalVisits > 1 ? '${settings.translate("Perform Visit")} ${item.currentVisit}' : settings.translate('Perform Procedure')),
                      ),
                      onPressed: () => _openProcedureChart(context, item),
                    ),
                  ],
                ],
              ),

              if (!widget.isReadOnly) ...[
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'delete') _confirmDeleteItem(context, item);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(settings.translate('Delete Procedure')),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
