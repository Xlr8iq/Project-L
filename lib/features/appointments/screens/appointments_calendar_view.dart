import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/appointment.dart';
import '../../../core/models/patient.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../odontogram/screens/charting_screen.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../dashboard/providers/settings_provider.dart';

class AppointmentsCalendarView extends StatefulWidget {
  const AppointmentsCalendarView({Key? key}) : super(key: key);

  @override
  State<AppointmentsCalendarView> createState() => _AppointmentsCalendarViewState();
}

class _AppointmentsCalendarViewState extends State<AppointmentsCalendarView> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _baseDate;

  @override
  void initState() {
    super.initState();
    _baseDate = DateTime.now();
  }

  List<DateTime> _generateDays() {
    return List.generate(30, (index) => _baseDate.add(Duration(days: index - 15)));
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment, Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailModal(appointment: appointment, patient: patient),
    );
  }

  Future<void> _pickDate() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: settings.isArabic ? const Locale('ar', 'SA') : const Locale('en', 'US'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _baseDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _generateDays();
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(settings.translate('Calendar'), style: Theme.of(context).textTheme.headlineMedium),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                onPressed: _pickDate,
                tooltip: settings.translate('Calendar'),
              ),
            ],
          ),
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
                  duration: const Duration(milliseconds: 200),
                  width: 75,
                  margin: EdgeInsets.only(left: index == 0 ? 24 : 8, right: index == days.length - 1 ? 24 : 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isToday && !isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                      width: isToday && !isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.25), blurRadius: 8, spreadRadius: 1)]
                        : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        settings.formatMonthShort(date),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        settings.formatWeekdayShort(date),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
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
                  child: Text(
                    settings.translate('No appointments scheduled for today.'),
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                itemCount: dailyAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = dailyAppointments[index];
                  final patient = provider.getPatientById(appointment.patientId);
                  if (patient == null) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAppointmentDetails(context, appointment, patient),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                settings.formatTime(appointment.dateTime),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patient.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${settings.translate("Type:")} ${settings.translate(appointment.notes.isNotEmpty ? appointment.notes : "Checkup / Consultation")}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${settings.translate("Doctor:")} ${appointment.doctorName}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
                                    color: appointment.status == 'Completed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    settings.translate(appointment.status),
                                    style: TextStyle(
                                      color: appointment.status == 'Completed' ? Colors.green.shade700 : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  icon: const Icon(Icons.print, size: 16),
                                  label: Text(settings.translate('Print Rx'), style: const TextStyle(fontSize: 12)),
                                  onPressed: () {
                                    PdfGenerator.printPrescription(patient: patient, appointment: appointment, settings: settings);
                                  },
                                ),
                              ],
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

  const _AppointmentDetailModal({Key? key, required this.appointment, required this.patient}) : super(key: key);

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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final updated = widget.appointment.copyWith(
      notes: _notesController.text,
      workPerformed: _workPerformedController.text,
      outcomes: _outcomesController.text,
      medications: _medicationsController.text,
      status: _status,
    );

    final provider = Provider.of<ClinicProvider>(context, listen: false);
    await provider.updateAppointment(updated);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(settings.translate('Appointment scheduled successfully for')), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.patient.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 22, color: AppTheme.textPrimary),
                    ),
                    Text(
                      settings.translate('Appointment Status'),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.medical_services),
                  label: Text(settings.translate('Open Chart')),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChartingScreen(patient: widget.patient)),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: AppTheme.borderLight),
            const SizedBox(height: 16),

            // Status Selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(settings.translate('Scheduled'), style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold)),
                    value: 'Scheduled',
                    groupValue: _status,
                    activeColor: Colors.orange.shade800,
                    onChanged: (val) => setState(() => _status = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text(settings.translate('Completed'), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
              decoration: InputDecoration(labelText: settings.translate('Administrative Notes (Optional)')),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _workPerformedController,
              decoration: InputDecoration(labelText: settings.translate('Work Performed')),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _outcomesController,
              decoration: InputDecoration(labelText: settings.translate('Outcomes & Doctor Notes')),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _medicationsController,
              decoration: InputDecoration(
                labelText: settings.translate('Medications Prescribed'),
                hintText: '1. Medication A\n2. Medication B',
              ),
              minLines: 3,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(18),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _save(context),
              child: Text(settings.translate('Save')),
            ),
          ],
        ),
      ),
    );
  }
}
