import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/treatment_plan_item.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../odontogram/screens/charting_screen.dart';
import '../../treatment_plan/screens/treatment_plan_screen.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../dashboard/providers/settings_provider.dart';

class PatientProfileScreen extends StatefulWidget {
  final Patient patient;

  const PatientProfileScreen({Key? key, required this.patient}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClinicProvider>(context, listen: false).loadTreatmentPlan(widget.patient.id!);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPastAppointmentDetails(BuildContext context, Appointment appointment) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${settings.translate("Appointment Details")} (${settings.formatDate(appointment.dateTime)})',
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection(
                settings.translate('Status'),
                settings.translate(appointment.status),
                appointment.status == 'Completed' ? Colors.green.shade700 : Colors.orange.shade800,
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                settings.translate('Reason / Notes'),
                appointment.notes.isEmpty ? settings.translate('N/A') : appointment.notes,
                AppTheme.textPrimary,
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                settings.translate('Work Performed'),
                appointment.workPerformed.isEmpty ? settings.translate('None recorded') : appointment.workPerformed,
                AppTheme.textPrimary,
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                settings.translate('Outcomes & Doctor Notes'),
                appointment.outcomes.isEmpty ? settings.translate('None recorded') : appointment.outcomes,
                AppTheme.textPrimary,
              ),
              const SizedBox(height: 16),
              _buildDetailSection(
                settings.translate('Medications'),
                appointment.medications.isEmpty ? settings.translate('None prescribed') : appointment.medications,
                AppTheme.textPrimary,
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.print, size: 16),
            label: Text(settings.translate('Print Prescription')),
            onPressed: () {
              Navigator.pop(context);
              PdfGenerator.printPrescription(patient: widget.patient, appointment: appointment, settings: settings);
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(settings.translate('Close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: contentColor, fontSize: 15)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('${settings.translate("Patient Profile")}: ${widget.patient.name}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
              icon: const Icon(Icons.list_alt),
              label: Text(settings.translate('Treatment Plan')),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TreatmentPlanScreen(patient: widget.patient)),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
              icon: const Icon(Icons.add_chart),
              label: Text(settings.translate('Open Chart')),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChartingScreen(patient: widget.patient)));
              },
            ),
          )
        ],
      ),
      body: Consumer<ClinicProvider>(
        builder: (context, provider, child) {
          final history = provider.getAppointmentsForPatient(widget.patient.id!);
          final treatmentPlan = provider.getTreatmentPlan(widget.patient.id!);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Demographics & Quick Actions
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 54, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.patient.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${settings.translate("Registered")}: ${settings.formatDate(widget.patient.createdAt)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        icon: const Icon(Icons.assignment_turned_in),
                        label: Text(settings.translate('Open Treatment Plan')),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TreatmentPlanScreen(patient: widget.patient)),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppTheme.borderLight),
                      const SizedBox(height: 16),
                      _buildDemoRow(Icons.cake, settings.translate('Age *'), '${widget.patient.age}'),
                      _buildDemoRow(Icons.wc, settings.translate('Gender *'), settings.translate(widget.patient.gender)),
                      _buildDemoRow(Icons.phone, settings.translate('Phone Number *'), widget.patient.phone.isNotEmpty ? widget.patient.phone : settings.translate('N/A')),
                      _buildDemoRow(Icons.medical_information, settings.translate('Patient ID'), '#${widget.patient.id.toString().padLeft(4, '0')}'),
                    ],
                  ),
                ),
              ),

              const VerticalDivider(width: 1, color: AppTheme.borderLight),

              // Right Column: Tabs (Treatment Plan Roadmap vs Appointment History)
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: AppTheme.primaryBlue,
                        unselectedLabelColor: AppTheme.textSecondary,
                        indicatorColor: AppTheme.primaryBlue,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                            icon: const Icon(Icons.assignment_outlined),
                            text: '${settings.translate("Treatment Plan")} (${treatmentPlan.length})',
                          ),
                          Tab(
                            icon: const Icon(Icons.history),
                            text: '${settings.translate("Appointment History")} (${history.length})',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // TAB 1: Treatment Plan Items View
                            _buildTreatmentPlanTab(context, treatmentPlan, settings),

                            // TAB 2: Appointment History View
                            _buildHistoryTab(context, history, settings),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTreatmentPlanTab(BuildContext context, List<TreatmentPlanItem> items, SettingsProvider settings) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 54, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              settings.translate('No treatment plan items found.'),
              style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_chart),
              label: Text(settings.translate('+ Diagnose / Open Chart')),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChartingScreen(patient: widget.patient)));
              },
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.statusColor.withOpacity(0.1),
              child: Icon(item.statusIcon, color: item.statusColor, size: 20),
            ),
            title: Text(
              settings.translate(item.procedureName),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text('${settings.translate("Tooth")}: ${item.palmerDisplay} • ${settings.translate(item.statusDisplay)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.formatCurrency(item.estimatedFee),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TreatmentPlanScreen(patient: widget.patient)),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(BuildContext context, List<Appointment> history, SettingsProvider settings) {
    if (history.isEmpty) {
      return Center(
        child: Text(
          settings.translate('No past appointments found.'),
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final appt = history[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showPastAppointmentDetails(context, appt),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      settings.formatDate(appt.dateTime),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt.notes.isNotEmpty ? appt.notes : settings.translate('Check-up'),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${settings.translate("Work Performed")}: ${appt.workPerformed.isNotEmpty ? appt.workPerformed : settings.translate("None recorded")}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: appt.status == 'Completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          settings.translate(appt.status),
                          style: TextStyle(
                            color: appt.status == 'Completed' ? Colors.green.shade700 : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.translate('View Details >'),
                        style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDemoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
            ],
          )
        ],
      ),
    );
  }
}
