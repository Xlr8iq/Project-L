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

  // Patient Selection / Creation State
  bool _isNewPatient = false;
  Patient? _selectedPatient;
  final TextEditingController _searchController = TextEditingController();

  // Patient Form Fields
  String _fullName = '';
  String _phoneNumber = '';
  String _secondPhoneNumber = '';
  DateTime? _dateOfBirth;
  int _calculatedAge = 0;
  String _gender = 'Male';
  String _address = '';
  String _patientNotes = '';

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

  // Focus node & overlay for search dropdown
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchDropdown = false;
  List<Patient> _filteredPatients = [];

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
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      setState(() {
        _showSearchDropdown = _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    final provider = Provider.of<ClinicProvider>(context, listen: false);

    if (query.isEmpty) {
      setState(() {
        _filteredPatients = [];
        _showSearchDropdown = false;
      });
      return;
    }

    setState(() {
      _filteredPatients = provider.patients.where((p) {
        final idStr = p.id != null ? '#${p.id.toString().padLeft(4, '0')}' : '';
        final idNum = p.id != null ? p.id.toString() : '';
        final nameMatch = p.name.toLowerCase().contains(query);
        final idMatch = idStr.toLowerCase().contains(query) || idNum.contains(query);
        return nameMatch || idMatch;
      }).toList();
      _showSearchDropdown = _searchFocusNode.hasFocus;
    });
  }

  void _selectExistingPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _isNewPatient = false;
      _fullName = patient.name;
      _calculatedAge = patient.age;
      _gender = patient.gender;
      _searchController.text = '${patient.name} (#${patient.id.toString().padLeft(4, '0')})';
      _showSearchDropdown = false;
      _searchFocusNode.unfocus();
    });
  }

  void _switchToNewPatient() {
    setState(() {
      _selectedPatient = null;
      _isNewPatient = true;
      _searchController.clear();
      _fullName = '';
      _phoneNumber = '';
      _secondPhoneNumber = '';
      _dateOfBirth = null;
      _calculatedAge = 0;
      _gender = 'Male';
      _address = '';
      _patientNotes = '';
      _showSearchDropdown = false;
      _searchFocusNode.unfocus();
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
    final balance = _consultationFee - _paidToday;
    return balance < 0 ? 0.0 : balance;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isNewPatient && _selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an existing patient or click "+ Create New Patient".'),
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
        if (_isNewPatient) {
          final ageToSave = _dateOfBirth != null ? _calculatedAge : (_calculatedAge > 0 ? _calculatedAge : 25);
          patient = await provider.addPatient(_fullName, ageToSave, _gender);
        } else {
          patient = _selectedPatient!;
        }

        // Construct administrative note combining notes, type, doctor, and payment summary
        final combinedNotes = [
          if (_appointmentType.isNotEmpty) 'Type: $_appointmentType',
          if (_selectedDoctor.isNotEmpty) 'Doctor: $_selectedDoctor',
          if (_adminNotes.isNotEmpty) _adminNotes,
          'Fee: \$${_consultationFee.toStringAsFixed(2)} | Paid: \$${_paidToday.toStringAsFixed(2)} | Bal: \$${_remainingBalance.toStringAsFixed(2)} ($_paymentMethod)',
        ].join(' • ');

        final appointment = await provider.addAppointment(patient.id!, fullDateTime, combinedNotes);
        
        // Update appointment status
        if (_appointmentStatus != 'Scheduled') {
          await provider.updateAppointment(appointment.copyWith(status: _appointmentStatus));
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment saved successfully for ${patient.name}!'),
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
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── CARD 1: PATIENT ───
                  _buildCard(
                    title: 'Patient',
                    icon: Icons.person_search,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Autocomplete Search Field
                        const Text(
                          'Search Patient',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Column(
                              children: [
                                TextFormField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Type Patient Name, Phone Number, or ID...',
                                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryBlue),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {
                                                _selectedPatient = null;
                                                _fullName = '';
                                              });
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Dropdown Search Results
                        if (_showSearchDropdown && _filteredPatients.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.4), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
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
                                    radius: 16,
                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                    child: const Icon(Icons.person, size: 18, color: AppTheme.primaryBlue),
                                  ),
                                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('${p.age} y/o • ${p.gender} • ID: #${p.id.toString().padLeft(4, '0')}'),
                                  onTap: () => _selectExistingPatient(p),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Create New Patient Button / Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_selectedPatient != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade600),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Selected: ${_selectedPatient!.name}',
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              )
                            else if (!_isNewPatient)
                              const Text(
                                'No patient selected yet.',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                            OutlinedButton.icon(
                              onPressed: _switchToNewPatient,
                              icon: const Icon(Icons.person_add, size: 18),
                              label: Text(_isNewPatient ? 'Reset Form' : '+ Create New Patient'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(color: AppTheme.primaryBlue),
                              ),
                            ),
                          ],
                        ),

                        // ─── READ-ONLY SECRETARY PREVIEW (If existing patient selected) ───
                        if (_selectedPatient != null) ...[
                          const SizedBox(height: 16),
                          _buildReadOnlyTreatmentPreview(_selectedPatient!),
                        ],

                        // ─── EXPANDABLE NEW PATIENT FORM ───
                        if (_isNewPatient) ...[
                          const SizedBox(height: 20),
                          const Divider(color: AppTheme.borderLight),
                          const SizedBox(height: 16),
                          const Text(
                            'New Patient Information',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),

                          // Required: Full Name & Phone Number
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name *',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Full Name is required' : null,
                                  onSaved: (val) => _fullName = val!.trim(),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number *',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Phone Number is required' : null,
                                  onSaved: (val) => _phoneNumber = val!.trim(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Optional: Second Phone Number & Date of Birth
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Second Phone Number (Optional)',
                                    prefixIcon: Icon(Icons.phone_android),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  onSaved: (val) => _secondPhoneNumber = val?.trim() ?? '',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: _pickDateOfBirth,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Date of Birth (Optional)',
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
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Auto-calculated Age & Sex Selection
                          Row(
                            children: [
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
                                            _dateOfBirth != null ? '$_calculatedAge years old' : 'Auto-calculated on DOB pick',
                                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Sex',
                                    prefixIcon: Icon(Icons.wc),
                                  ),
                                  value: _gender,
                                  items: ['Male', 'Female', 'Other']
                                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _gender = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Address & Notes
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Address (Optional)',
                              prefixIcon: Icon(Icons.home_outlined),
                            ),
                            onSaved: (val) => _address = val?.trim() ?? '',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Patient Notes (Optional)',
                              prefixIcon: Icon(Icons.note_alt_outlined),
                            ),
                            maxLines: 2,
                            onSaved: (val) => _patientNotes = val?.trim() ?? '',
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── CARD 2: APPOINTMENT ───
                  _buildCard(
                    title: 'Appointment',
                    icon: Icons.event,
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

                        // Automatic Remaining Balance Display
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
