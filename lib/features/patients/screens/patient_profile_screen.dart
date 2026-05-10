import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../odontogram/screens/charting_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final Patient patient;

  const PatientProfileScreen({Key? key, required this.patient}) : super(key: key);

  void _showPastAppointmentDetails(BuildContext context, Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Text('Appointment on ${DateFormat('MMM d, yyyy').format(appointment.dateTime)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection('Status', appointment.status, appointment.status == 'Completed' ? Colors.green : Colors.orange),
              const SizedBox(height: 16),
              _buildDetailSection('Reason / Notes', appointment.notes.isEmpty ? 'N/A' : appointment.notes, Colors.white),
              const SizedBox(height: 16),
              _buildDetailSection('Work Performed', appointment.workPerformed.isEmpty ? 'None recorded' : appointment.workPerformed, Colors.white),
              const SizedBox(height: 16),
              _buildDetailSection('Outcomes & Doctor Notes', appointment.outcomes.isEmpty ? 'None recorded' : appointment.outcomes, Colors.white),
              const SizedBox(height: 16),
              _buildDetailSection('Medications', appointment.medications.isEmpty ? 'None prescribed' : appointment.medications, Colors.white),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.accentCyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, Color contentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(color: contentColor, fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.black),
              icon: const Icon(Icons.add_chart),
              label: const Text('Open Chart'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChartingScreen(patient: patient)));
              },
            ),
          )
        ],
      ),
      body: Consumer<ClinicProvider>(
        builder: (context, provider, child) {
          final history = provider.getAppointmentsForPatient(patient.id!);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Demographics
              Expanded(
                flex: 1,
                child: Container(
                  color: AppTheme.surfaceDark,
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const CircleAvatar(radius: 60, backgroundColor: AppTheme.backgroundDark, child: Icon(Icons.person, size: 60, color: AppTheme.accentCyan)),
                      const SizedBox(height: 24),
                      Text(patient.name, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Registered: ${DateFormat('MMM d, yyyy').format(patient.createdAt)}', style: const TextStyle(color: Colors.white54)),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 16),
                      _buildDemoRow(Icons.cake, 'Age', '${patient.age} years old'),
                      _buildDemoRow(Icons.wc, 'Gender', patient.gender),
                      _buildDemoRow(Icons.medical_information, 'Patient ID', '#${patient.id.toString().padLeft(4, '0')}'),
                    ],
                  ),
                ),
              ),

              // Right Column: History
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Appointment History', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.accentCyan)),
                      const SizedBox(height: 24),
                      if (history.isEmpty)
                        const Expanded(child: Center(child: Text('No past appointments found.', style: TextStyle(color: Colors.white54, fontSize: 18))))
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final appt = history[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showPastAppointmentDetails(context, appt),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(12)),
                                          child: Column(
                                            children: [
                                              Text(DateFormat('MMM').format(appt.dateTime).toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                              Text(DateFormat('d').format(appt.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: AppTheme.accentCyan)),
                                              Text(DateFormat('yyyy').format(appt.dateTime), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(appt.notes.isNotEmpty ? appt.notes : 'General Checkup', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                              const SizedBox(height: 8),
                                              Text('Work: ${appt.workPerformed.isNotEmpty ? appt.workPerformed : 'None recorded'}', style: const TextStyle(color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: appt.status == 'Completed' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                appt.status,
                                                style: TextStyle(color: appt.status == 'Completed' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text('View Details >', style: TextStyle(color: AppTheme.accentCyan, fontSize: 12)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
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

  Widget _buildDemoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentCyan, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
}
