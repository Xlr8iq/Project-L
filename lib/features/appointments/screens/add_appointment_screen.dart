import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/appointment.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../dashboard/providers/settings_provider.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Single Patient Name Controller
  final TextEditingController _patientNameController = TextEditingController();
  final FocusNode _patientFocusNode = FocusNode();
  
  Patient? _selectedPatient;
  List<Patient> _filteredPatients = [];
  bool _showDropdown = false;

  // Appointment Form Fields
  DateTime _appointmentDate = DateTime.now();
  TimeOfDay _appointmentTime = TimeOfDay.now();
  String _selectedDoctor = 'Dr. Alex Smith';
  String _appointmentType = 'Consultation';
  String _adminNotes = '';

  // Payment Fields
  double _consultationFee = 25.0;
  double _paidToday = 10.0;
  String _paymentMethod = 'Cash';

  // Status Field
  String _appointmentStatus = 'Scheduled';

  final List<String> _doctors = [
    'Dr. Alex Smith',
    'Dr. Sarah Johnson',
    'Dr. Michael Chen',
    'Dr. Emily Taylor',
  ];

  final List<String> _appointmentTypes = [
    'New Patient',
    'Follow-up',
    'Emergency',
    'Consultation',
  ];

  final List<String> _paymentMethods = [
    'Cash',
    'Card',
    'Bank Transfer',
  ];

  final List<String> _statusOptions = [
    'Scheduled',
    'Arrived',
    'In Treatment',
    'Completed',
    'Cancelled',
    'No Show',
  ];

  @override
  void initState() {
    super.initState();
    _patientNameController.addListener(_onPatientNameChanged);
    _patientFocusNode.addListener(() {
      setState(() {
        _showDropdown = _patientFocusNode.hasFocus && _filteredPatients.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _patientNameController.removeListener(_onPatientNameChanged);
    _patientNameController.dispose();
    _patientFocusNode.dispose();
    super.dispose();
  }

  void _onPatientNameChanged() {
    final query = _patientNameController.text.trim().toLowerCase();
    final provider = Provider.of<ClinicProvider>(context, listen: false);

    // If user edited text manually after selecting a patient, reset selected patient reference if name no longer matches
    if (_selectedPatient != null && _selectedPatient!.name.toLowerCase() != query) {
      setState(() {
        _selectedPatient = null;
      });
    }

    if (query.isEmpty) {
      setState(() {
        _filteredPatients = [];
        _showDropdown = false;
      });
      return;
    }

    final matches = provider.patients.where((p) {
      final nameMatch = p.name.toLowerCase().contains(query);
      final idStr = p.id != null ? '#${p.id.toString().padLeft(4, '0')}' : '';
      final idMatch = idStr.contains(query);
      return nameMatch || idMatch;
    }).toList();

    setState(() {
      _filteredPatients = matches;
      _showDropdown = _patientFocusNode.hasFocus && matches.isNotEmpty;
    });
  }

  void _selectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _patientNameController.text = patient.name;
      _showDropdown = false;
      _patientFocusNode.unfocus();
    });
  }

  Future<void> _pickAppointmentDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _appointmentDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
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
        _appointmentDate = picked;
      });
    }
  }

  Future<void> _pickAppointmentTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _appointmentTime,
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
        _appointmentTime = picked;
      });
    }
  }

  double get _remainingBalance {
    final balance = _consultationFee - _paidToday;
    return balance < 0 ? 0.0 : balance;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final nameInput = _patientNameController.text.trim();
      if (nameInput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a patient name.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      final fullDateTime = DateTime(
        _appointmentDate.year,
        _appointmentDate.month,
        _appointmentDate.day,
        _appointmentTime.hour,
        _appointmentTime.minute,
      );

      final provider = Provider.of<ClinicProvider>(context, listen: false);

      try {
        Patient patient;
        if (_selectedPatient != null) {
          patient = _selectedPatient!;
        } else {
          // Check if an exact name match already exists in database
          final existing = provider.patients.where(
            (p) => p.name.toLowerCase() == nameInput.toLowerCase(),
          ).toList();

          if (existing.isNotEmpty) {
            patient = existing.first;
          } else {
            // Automatically create a new patient with typed name
            patient = await provider.addPatient(nameInput, 25, 'Unspecified');
          }
        }

        // Construct administrative notes
        final combinedNotes = [
          if (_appointmentType.isNotEmpty) 'Type: $_appointmentType',
          if (_selectedDoctor.isNotEmpty) 'Doctor: $_selectedDoctor',
          if (_adminNotes.isNotEmpty) _adminNotes,
          'Fee: \$${_consultationFee.toStringAsFixed(2)} | Paid: \$${_paidToday.toStringAsFixed(2)} | Bal: \$${_remainingBalance.toStringAsFixed(2)} ($_paymentMethod)',
        ].join(' • ');

        final appointment = await provider.addAppointment(patient.id!, fullDateTime, combinedNotes);

        if (_appointmentStatus != 'Scheduled') {
          await provider.updateAppointment(appointment.copyWith(status: _appointmentStatus));
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment scheduled successfully for ${patient.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        title: Text(
          settings.translate('New Appointment'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── CARD 1: PATIENT ───
                  _buildCard(
                    title: 'Patient',
                    icon: Icons.person_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Single patient name text box with autocomplete dropdown
                        Column(
                          children: [
                            TextFormField(
                              controller: _patientNameController,
                              focusNode: _patientFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Write patient name...',
                                prefixIcon: const Icon(Icons.person, color: AppTheme.primaryBlue),
                                suffixIcon: _patientNameController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          _patientNameController.clear();
                                          setState(() {
                                            _selectedPatient = null;
                                            _filteredPatients = [];
                                            _showDropdown = false;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              validator: (val) => val == null || val.trim().isEmpty ? 'Please write patient name' : null,
                            ),

                            // Dropdown Menu for Existing Patients
                            if (_showDropdown && _filteredPatients.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                constraints: const BoxConstraints(maxHeight: 220),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _filteredPatients.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderLight),
                                  itemBuilder: (context, index) {
                                    final p = _filteredPatients[index];
                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                        child: const Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                                      ),
                                      title: Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        'ID: #${p.id.toString().padLeft(4, '0')} • ${p.age} y/o • ${p.gender}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onTap: () => _selectPatient(p),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),

                        // Selection Badge / Existing Patient Info
                        if (_selectedPatient != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Existing Patient #${_selectedPatient!.id.toString().padLeft(4, '0')} (${_selectedPatient!.age} y/o)',
                                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyTreatmentPreview(_selectedPatient!),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── CARD 2: APPOINTMENT ───
                  _buildCard(
                    title: 'Appointment',
                    icon: Icons.event_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.calendar_month, color: AppTheme.primaryBlue),
                                label: Text(DateFormat('EEE, MMM dd, yyyy').format(_appointmentDate)),
                                onPressed: _pickAppointmentDate,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.access_time, color: AppTheme.primaryBlue),
                                label: Text(_appointmentTime.format(context)),
                                onPressed: _pickAppointmentTime,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Doctor',
                                  prefixIcon: Icon(Icons.medical_services_outlined),
                                ),
                                value: _selectedDoctor,
                                items: _doctors
                                    .map((doc) => DropdownMenuItem(value: doc, child: Text(doc)))
                                    .toList(),
                                onChanged: (val) => setState(() => _selectedDoctor = val!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Appointment Type',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                value: _appointmentType,
                                items: _appointmentTypes
                                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                    .toList(),
                                onChanged: (val) => setState(() => _appointmentType = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Administrative Notes (Optional)',
                            hintText: 'e.g. Patient has pain. Requested afternoon appointment.',
                            prefixIcon: Icon(Icons.edit_note),
                          ),
                          maxLines: 2,
                          onSaved: (val) => _adminNotes = val?.trim() ?? '',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── CARD 3: PAYMENT ───
                  _buildCard(
                    title: 'Payment',
                    icon: Icons.payments_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _consultationFee.toStringAsFixed(0),
                                decoration: const InputDecoration(
                                  labelText: 'Consultation Fee (\$) *',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) => val == null || double.tryParse(val) == null ? 'Required' : null,
                                onChanged: (val) {
                                  setState(() {
                                    _consultationFee = double.tryParse(val) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                initialValue: _paidToday.toStringAsFixed(0),
                                decoration: const InputDecoration(
                                  labelText: 'Paid Today (\$) *',
                                  prefixIcon: Icon(Icons.price_check),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                validator: (val) => val == null || double.tryParse(val) == null ? 'Required' : null,
                                onChanged: (val) {
                                  setState(() {
                                    _paidToday = double.tryParse(val) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Payment Method',
                                  prefixIcon: Icon(Icons.credit_card),
                                ),
                                value: _paymentMethod,
                                items: _paymentMethods
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                    .toList(),
                                onChanged: (val) => setState(() => _paymentMethod = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Remaining Balance Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: _remainingBalance > 0 ? Colors.orange.withOpacity(0.08) : Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _remainingBalance > 0 ? Colors.orange.shade400 : Colors.green.shade400,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _remainingBalance > 0 ? Icons.pending_actions : Icons.check_circle_outline,
                                    color: _remainingBalance > 0 ? Colors.orange.shade800 : Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Remaining Balance:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: _remainingBalance > 0 ? Colors.orange.shade900 : Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '\$${_remainingBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: _remainingBalance > 0 ? Colors.orange.shade900 : Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── CARD 4: APPOINTMENT STATUS ───
                  _buildCard(
                    title: 'Appointment Status',
                    icon: Icons.fact_check_outlined,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Current Status',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      value: _appointmentStatus,
                      items: _statusOptions
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _appointmentStatus = val!),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ─── BOTTOM ACTION BUTTONS ───
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                            foregroundColor: AppTheme.textPrimary,
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 2,
                          ),
                          child: const Text('Save Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildReadOnlyTreatmentPreview(Patient patient) {
    final provider = Provider.of<ClinicProvider>(context, listen: false);
    final history = provider.getAppointmentsForPatient(patient.id!);
    final latestAppt = history.isNotEmpty ? history.first : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.lock_outline, size: 16, color: AppTheme.primaryBlue),
                  SizedBox(width: 6),
                  Text(
                    "Today's Treatment Plan (Read-Only)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Doctor Mode Only',
                  style: TextStyle(fontSize: 10, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (latestAppt != null && latestAppt.workPerformed.isNotEmpty) ...[
            Text(
              latestAppt.workPerformed,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Notes: ${latestAppt.notes.isNotEmpty ? latestAppt.notes : "Standard Checkup"}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ] else ...[
            const Text(
              'No active clinical treatment planned by doctor for today.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
