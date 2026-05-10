import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/patient.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../odontogram/screens/charting_screen.dart';

class AppointmentsCalendarView extends StatefulWidget {
  const AppointmentsCalendarView({Key? key}) : super(key: key);

  @override
  State<AppointmentsCalendarView> createState() => _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  DateTime _selectedDate = DateTime.now();

  List<DateTime> _generateDays() {
    final today = DateTime.now();
    return List.generate(30, (index) => today.add(Duration(days: index - 15)));
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment, Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailModal(appointment: appointment, patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Text('Calendar', style: Theme.of(context).textTheme.headlineMedium),
        ),
        
        // Horizontal Date Selector
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;
              final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70,
                  margin: EdgeInsets.only(left: index == 0 ? 24 : 8, right: index == days.length - 1 ? 24 : 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.accentCyan : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isToday && !isSelected ? AppTheme.accentCyan : Colors.transparent, width: 2),
                    boxShadow: isSelected ? [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)] : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('MMM').format(date).toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black54 : Colors.white54)),
                      const SizedBox(height: 4),
                      Text(DateFormat('d').format(date), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isSelected ? Colors.black : Colors.white)),
                      const SizedBox(height: 4),
                      Text(DateFormat('E').format(date), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.black54 : Colors.white54)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),
        
        // Appointments List
        Expanded(
          child: Consumer<ClinicProvider>(
            builder: (context, provider, child) {
              final dailyAppointments = provider.appointments.where((a) => a.dateTime.year == _selectedDate.year && a.dateTime.month == _selectedDate.month && a.dateTime.day == _selectedDate.day).toList();

              if (dailyAppointments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text('No appointments for this date.', style: TextStyle(color: Colors.white54, fontSize: 18)),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: dailyAppointments.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final appointment = dailyAppointments[index];
                  final patient = provider.getPatientById(appointment.patientId);
                  if (patient == null) return const SizedBox.shrink();

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.backgroundDark)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showAppointmentDetails(context, appointment, patient),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                children: [
                                  Text(DateFormat('hh:mm').format(appointment.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.accentCyan)),
                                  Text(DateFormat('a').format(appointment.dateTime), style: const TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(patient.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text(appointment.notes.isNotEmpty ? appointment.notes : 'General Checkup', style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: appointment.status == 'Completed' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                appointment.status,
                                style: TextStyle(
                                  color: appointment.status == 'Completed' ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AppointmentDetailModal extends StatefulWidget {
  final Appointment appointment;
  final Patient patient;

  const _AppointmentDetailModal({required this.appointment, required this.patient});

  @override
  State<_AppointmentDetailModal> createState() => _AppointmentDetailModalState();
}

class _AppointmentDetailModalState extends State<_AppointmentDetailModal> {
  late TextEditingController _notesController;
  late TextEditingController _workPerformedController;
  late TextEditingController _outcomesController;
  late TextEditingController _medicationsController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.appointment.notes);
    _workPerformedController = TextEditingController(text: widget.appointment.workPerformed);
    _outcomesController = TextEditingController(text: widget.appointment.outcomes);
    _medicationsController = TextEditingController(text: widget.appointment.medications);
    _status = widget.appointment.status;
  }

  void _save(BuildContext context) async {
    final updatedAppt = widget.appointment.copyWith(
      notes: _notesController.text,
      workPerformed: _workPerformedController.text,
      outcomes: _outcomesController.text,
      medications: _medicationsController.text,
      status: _status,
    );
    await Provider.of<ClinicProvider>(context, listen: false).updateAppointment(updatedAppt);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment updated!'), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 24),
                
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appointment Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.accentCyan)),
                        const SizedBox(height: 4),
                        Text('${widget.patient.name} • ${DateFormat('MMM d, yyyy - hh:mm a').format(widget.appointment.dateTime)}', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.black),
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ChartingScreen(patient: widget.patient)));
                      },
                      child: const Text('Open Chart'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Status Toggle
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Scheduled', style: TextStyle(color: Colors.white)),
                        value: 'Scheduled',
                        groupValue: _status,
                        activeColor: AppTheme.accentCyan,
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Completed', style: TextStyle(color: Colors.green)),
                        value: 'Completed',
                        groupValue: _status,
                        activeColor: Colors.green,
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Reason for Visit / Notes', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _workPerformedController,
                  decoration: const InputDecoration(labelText: 'Work Performed (Procedures, Treatments)', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _outcomesController,
                  decoration: const InputDecoration(labelText: 'Outcomes & Doctor Notes', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _medicationsController,
                  decoration: const InputDecoration(labelText: 'Medications Prescribed', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.all(20),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _save(context),
                  child: const Text('Save Details'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
