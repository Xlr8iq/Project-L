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

  // Patient Controllers & FocusNode
  final TextEditingController _patientSearchController = TextEditingController();
  final FocusNode _patientFocusNode = FocusNode();

  Patient? _selectedPatient;
  bool _isNewPatient = true;

  // New Patient Form State / Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();
  final TextEditingController _patientNotesController = TextEditingController();

  String _gender = 'Male';
  DateTime? _dateOfBirth;
  int _calculatedAge = 0;

  // Appointment Form Fields
  DateTime _appointmentDate = DateTime.now();
  TimeOfDay _appointmentTime = TimeOfDay.now();
  String _selectedDoctor = 'Dr. Alex Smith';
  String _appointmentType = 'Consultation';
  String _adminNotes = '';

  // Payment Toggle & Fields
  bool _chargeConsultationFee = false;
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
    _patientSearchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _patientSearchController.removeListener(_onSearchInputChanged);
    _patientSearchController.dispose();
    _patientFocusNode.dispose();

    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _patientNotesController.dispose();
    super.dispose();
  }

  void _onSearchInputChanged() {
    final text = _patientSearchController.text;
    if (_selectedPatient == null) {
      // Sync typed text to full name controller if creating new patient
      if (_fullNameController.text != text) {
        _fullNameController.text = text;
      }
    }
  }

  void _selectExistingPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _isNewPatient = false;
      _patientSearchController.text = patient.name;
      
      // Auto-populate all fields for reference
      _fullNameController.text = patient.name;
      _phoneController.text = patient.phone;
      _gender = patient.gender.isNotEmpty ? patient.gender : 'Male';
      _addressController.text = patient.address;
      _emergencyContactController.text = patient.emergencyContact;
      _emergencyPhoneController.text = patient.emergencyPhone;
      _dateOfBirth = patient.dateOfBirth;
      _calculatedAge = patient.dateOfBirth != null
          ? _calculateAgeFromDOB(patient.dateOfBirth!)
          : patient.age;
    });
  }

  void _clearSelectedPatient() {
    setState(() {
      _selectedPatient = null;
      _isNewPatient = true;
      _patientSearchController.clear();
      _fullNameController.clear();
      _phoneController.clear();
      _addressController.clear();
      _emergencyContactController.clear();
      _emergencyPhoneController.clear();
      _patientNotesController.clear();
      _gender = 'Male';
      _dateOfBirth = null;
      _calculatedAge = 0;
    });
  }

  int _calculateAgeFromDOB(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  Future<void> _pickDateOfBirth() async {
    final initial = _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
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
        _dateOfBirth = picked;
        _calculatedAge = _calculateAgeFromDOB(picked);
      });
    }
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
    if (!_chargeConsultationFee) return 0.0;
    final balance = _consultationFee - _paidToday;
    return balance < 0 ? 0.0 : balance;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final nameInput = _fullNameController.text.trim().isNotEmpty
          ? _fullNameController.text.trim()
          : _patientSearchController.text.trim();

      if (nameInput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write patient name.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Payment validation if fee is enabled
      if (_chargeConsultationFee && _paidToday > _consultationFee) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paid Today amount cannot exceed the Consultation Fee.'),
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
        if (_selectedPatient != null && _selectedPatient!.name.trim().toLowerCase() == nameInput.toLowerCase()) {
          patient = _selectedPatient!;
        } else {
          // Check if exact name match exists
          final existing = provider.patients.where(
            (p) => p.name.trim().toLowerCase() == nameInput.toLowerCase(),
          ).toList();

          if (existing.isNotEmpty) {
            patient = existing.first;
          } else {
            // Automatically create new patient with all specified details
            final ageToSave = _calculatedAge > 0 ? _calculatedAge : 25;
            patient = await provider.addPatient(
              nameInput,
              ageToSave,
              _gender,
              phone: _phoneController.text.trim(),
              address: _addressController.text.trim(),
              emergencyContact: _emergencyContactController.text.trim(),
              emergencyPhone: _emergencyPhoneController.text.trim(),
              dateOfBirth: _dateOfBirth,
            );
          }
        }

        // Construct administrative notes with fee summary if enabled
        final paymentSummary = _chargeConsultationFee
            ? 'Fee: \$${_consultationFee.toStringAsFixed(2)} | Paid: \$${_paidToday.toStringAsFixed(2)} | Bal: \$${_remainingBalance.toStringAsFixed(2)} ($_paymentMethod)'
            : 'No Consultation Fee';

        final combinedNotes = [
          if (_appointmentType.isNotEmpty) 'Type: $_appointmentType',
          if (_selectedDoctor.isNotEmpty) 'Doctor: $_selectedDoctor',
          if (_adminNotes.isNotEmpty) _adminNotes,
          paymentSummary,
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
                          'Search Patient',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Autocomplete Patient Search
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return RawAutocomplete<Patient>(
                              focusNode: _patientFocusNode,
                              textEditingController: _patientSearchController,
                              displayStringForOption: (Patient option) => option.name,
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                final query = textEditingValue.text.trim().toLowerCase();
                                if (query.isEmpty) {
                                  return const Iterable<Patient>.empty();
                                }
                                final provider = Provider.of<ClinicProvider>(context, listen: false);
                                return provider.patients.where((p) {
                                  final nameMatch = p.name.toLowerCase().contains(query);
                                  final phoneMatch = p.phone.contains(query);
                                  final idMatch = p.id != null && '#${p.id.toString().padLeft(4, '0')}'.contains(query);
                                  return nameMatch || phoneMatch || idMatch;
                                });
                              },
                              onSelected: (Patient selection) {
                                _selectExistingPatient(selection);
                              },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Type Patient Name, Phone, or ID...',
                                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                                    suffixIcon: controller.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 20),
                                            onPressed: _clearSelectedPatient,
                                          )
                                        : null,
                                  ),
                                  onChanged: (val) {
                                    if (_selectedPatient != null && _selectedPatient!.name != val) {
                                      setState(() {
                                        _selectedPatient = null;
                                        _isNewPatient = true;
                                      });
                                    }
                                  },
                                );
                              },
                              optionsViewBuilder: (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 6,
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white,
                                    child: Container(
                                      width: constraints.maxWidth,
                                      constraints: const BoxConstraints(maxHeight: 220),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4), width: 1.5),
                                      ),
                                      child: ListView.separated(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.borderLight),
                                        itemBuilder: (BuildContext context, int index) {
                                          final Patient option = options.elementAt(index);
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                              child: const Icon(Icons.person, size: 16, color: AppTheme.primaryBlue),
                                            ),
                                            title: Text(
                                              option.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              'ID: #${option.id.toString().padLeft(4, '0')} • ${option.age} y/o • ${option.gender}${option.phone.isNotEmpty ? " • ${option.phone}" : ""}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            onTap: () {
                                              onSelected(option);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        // ─── EXISTING PATIENT POPULATED CARD ───
                        if (_selectedPatient != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          _selectedPatient!.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
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
                                        'Patient ID: #${_selectedPatient!.id.toString().padLeft(4, '0')}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, color: AppTheme.borderLight),
                                Wrap(
                                  spacing: 24,
                                  runSpacing: 8,
                                  children: [
                                    _buildInfoChip(Icons.cake, 'Age / DOB', '${_selectedPatient!.age} y/o (${_selectedPatient!.gender})'),
                                    if (_selectedPatient!.phone.isNotEmpty)
                                      _buildInfoChip(Icons.phone, 'Phone', _selectedPatient!.phone),
                                    if (_selectedPatient!.address.isNotEmpty)
                                      _buildInfoChip(Icons.home, 'Address', _selectedPatient!.address),
                                    if (_selectedPatient!.emergencyContact.isNotEmpty)
                                      _buildInfoChip(
                                        Icons.emergency,
                                        'Emergency Contact',
                                        '${_selectedPatient!.emergencyContact} (${_selectedPatient!.emergencyPhone})',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyTreatmentPreview(_selectedPatient!),
                        ],

                        // ─── AUTO-EXPANDED NEW PATIENT FORM (If typed name not in DB) ───
                        if (_selectedPatient == null) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade400),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.person_add, color: Colors.amber, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Patient not found in database. New Patient form expanded below.',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black80),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'New Patient Information',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),

                          // Required Fields: Full Name, Gender, Phone Number
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _fullNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name *',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Full Name is required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Gender *',
                                    prefixIcon: Icon(Icons.wc),
                                  ),
                                  value: _gender,
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _gender = val!),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: _phoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number *',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Phone Number is required' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Optional Fields: Date of Birth & Auto-Calculated Age
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDateOfBirth,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date of Birth (Preferred)',
                                      prefixIcon: Icon(Icons.cake_outlined),
                                    ),
                                    child: Text(
                                      _dateOfBirth == null
                                          ? 'Select Date of Birth'
                                          : DateFormat('MMM dd, yyyy').format(_dateOfBirth!),
                                      style: TextStyle(
                                        color: _dateOfBirth == null ? AppTheme.textSecondary : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.06),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.numbers, color: AppTheme.primaryBlue, size: 20),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Age (Calculated from DOB)',
                                            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _dateOfBirth != null ? '$_calculatedAge years old' : 'Calculated on DOB pick',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Optional Fields: Address, Emergency Contact, Emergency Phone
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address (Optional)',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _emergencyContactController,
                                  decoration: const InputDecoration(
                                    labelText: 'Emergency Contact Name (Optional)',
                                    prefixIcon: Icon(Icons.contact_emergency_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _emergencyPhoneController,
                                  decoration: const InputDecoration(
                                    labelText: 'Emergency Contact Phone (Optional)',
                                    prefixIcon: Icon(Icons.phone_paused_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Optional: Patient Notes
                          TextFormField(
                            controller: _patientNotesController,
                            decoration: const InputDecoration(
                              labelText: 'Patient Notes (Optional)',
                              prefixIcon: Icon(Icons.note_alt_outlined),
                            ),
                            maxLines: 2,
                          ),
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

                  // ─── CARD 3: PAYMENT (With Consultation Fee Toggle) ───
                  _buildCard(
                    title: 'Payment',
                    icon: Icons.payments_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Consultation Fee Toggle Switch
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: _chargeConsultationFee ? AppTheme.primaryBlue.withOpacity(0.06) : Colors.green.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _chargeConsultationFee ? AppTheme.primaryBlue.withOpacity(0.4) : Colors.green.shade400,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _chargeConsultationFee ? Icons.price_check : Icons.money_off,
                                    color: _chargeConsultationFee ? AppTheme.primaryBlue : Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Charge Consultation Fee',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: _chargeConsultationFee ? AppTheme.primaryBlue : Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _chargeConsultationFee,
                                activeColor: AppTheme.primaryBlue,
                                onChanged: (val) {
                                  setState(() {
                                    _chargeConsultationFee = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),

                        // IF OFF: Show Free / Pay Later badge
                        if (!_chargeConsultationFee) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'No payment required today (Free consultation, recall, post-op review, or pay later).',
                                    style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // IF ON: Display Fee, Paid Today, Method & Auto-Calculated Remaining Balance
                        if (_chargeConsultationFee) ...[
                          const SizedBox(height: 20),
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
                                  validator: (val) {
                                    if (!_chargeConsultationFee) return null;
                                    if (val == null || double.tryParse(val) == null) return 'Required';
                                    return null;
                                  },
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
                                  validator: (val) {
                                    if (!_chargeConsultationFee) return null;
                                    final paid = double.tryParse(val ?? '');
                                    if (paid == null) return 'Required';
                                    if (paid > _consultationFee) return 'Exceeds Fee';
                                    return null;
                                  },
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

                          // Real-time Remaining Balance Bar
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

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryBlue),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
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
