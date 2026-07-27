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

  // Single Unified Full Name Controller & FocusNode
  final TextEditingController _fullNameController = TextEditingController();
  final FocusNode _fullNameFocusNode = FocusNode();

  Patient? _selectedPatient;

  // Patient Form Controllers
  final TextEditingController _ageController = TextEditingController(text: '25');
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _emergencyPhoneController = TextEditingController();

  String _gender = 'Male';

  // Appointment Form Fields
  DateTime _appointmentDate = DateTime.now();
  TimeOfDay _appointmentTime = TimeOfDay.now();
  String _selectedDoctor = '';
  String _appointmentType = 'Consultation';
  String _adminNotes = '';

  // Payment Toggle & Fields
  bool _chargeConsultationFee = false;
  double _consultationFee = 25.0;
  double _paidToday = 10.0;
  String _paymentMethod = 'Cash';

  // Status Field
  String _appointmentStatus = 'Scheduled';

  final List<String> _appointmentTypes = [
    'New Patient',
    'Follow-up',
    'Emergency',
    'Consultation',
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
    final provider = Provider.of<ClinicProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    _consultationFee = settings.defaultConsultationFee;

    if (provider.doctors.isNotEmpty) {
      _selectedDoctor = provider.doctors.first.name;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fullNameFocusNode.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _selectExistingPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _fullNameController.text = patient.name;
      _ageController.text = patient.age.toString();
      _phoneController.text = patient.phone;
      _gender = patient.gender.isNotEmpty ? patient.gender : 'Male';
      _addressController.text = patient.address;
      _emergencyContactController.text = patient.emergencyContact;
      _emergencyPhoneController.text = patient.emergencyPhone;
    });
  }

  void _clearSelectedPatient() {
    setState(() {
      _selectedPatient = null;
      _fullNameController.clear();
      _ageController.text = '25';
      _phoneController.clear();
      _addressController.clear();
      _emergencyContactController.clear();
      _emergencyPhoneController.clear();
      _gender = 'Male';
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
    if (!_chargeConsultationFee) return 0.0;
    final balance = _consultationFee - _paidToday;
    return balance < 0 ? 0.0 : balance;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final nameInput = _fullNameController.text.trim();

      if (nameInput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please write patient name.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (_chargeConsultationFee && _paidToday > _consultationFee) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paid Today amount cannot exceed Consultation Fee.'),
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
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      try {
        Patient patient;
        final ageVal = int.tryParse(_ageController.text.trim()) ?? 25;
        final phoneVal = _phoneController.text.trim();
        final addressVal = _addressController.text.trim();
        final emergencyContactVal = _emergencyContactController.text.trim();
        final emergencyPhoneVal = _emergencyPhoneController.text.trim();

        if (_selectedPatient != null && _selectedPatient!.name.trim().toLowerCase() == nameInput.toLowerCase()) {
          final updatedPatient = Patient(
            id: _selectedPatient!.id,
            name: nameInput,
            age: ageVal,
            gender: _gender,
            createdAt: _selectedPatient!.createdAt,
            phone: phoneVal,
            address: addressVal,
            emergencyContact: emergencyContactVal,
            emergencyPhone: emergencyPhoneVal,
            dateOfBirth: _selectedPatient!.dateOfBirth,
          );
          await provider.updatePatient(updatedPatient);
          patient = updatedPatient;
        } else {
          final existing = provider.patients.where(
            (p) => p.name.trim().toLowerCase() == nameInput.toLowerCase(),
          ).toList();

          if (existing.isNotEmpty) {
            final updatedPatient = Patient(
              id: existing.first.id,
              name: nameInput,
              age: ageVal,
              gender: _gender,
              createdAt: existing.first.createdAt,
              phone: phoneVal,
              address: addressVal,
              emergencyContact: emergencyContactVal,
              emergencyPhone: emergencyPhoneVal,
              dateOfBirth: existing.first.dateOfBirth,
            );
            await provider.updatePatient(updatedPatient);
            patient = updatedPatient;
          } else {
            patient = await provider.addPatient(
              nameInput,
              ageVal,
              _gender,
              phone: phoneVal,
              address: addressVal,
              emergencyContact: emergencyContactVal,
              emergencyPhone: emergencyPhoneVal,
            );
          }
        }

        final paymentSummary = _chargeConsultationFee
            ? 'Fee: ${settings.formatCurrency(_consultationFee)} | Paid: ${settings.formatCurrency(_paidToday)} | Bal: ${settings.formatCurrency(_remainingBalance)} ($_paymentMethod)'
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
    final provider = context.watch<ClinicProvider>();
    final doctorList = provider.doctors.map((d) => d.name).toList();

    if (doctorList.isNotEmpty && (_selectedDoctor.isEmpty || !doctorList.contains(_selectedDoctor))) {
      _selectedDoctor = doctorList.first;
    }

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
                    title: 'Patient Information',
                    icon: Icons.person_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return RawAutocomplete<Patient>(
                              focusNode: _fullNameFocusNode,
                              textEditingController: _fullNameController,
                              displayStringForOption: (Patient option) => option.name,
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                final query = textEditingValue.text.trim().toLowerCase();
                                if (query.isEmpty) {
                                  return const Iterable<Patient>.empty();
                                }
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
                                    labelText: 'Full Name *',
                                    hintText: 'Type patient full name (searches database automatically)...',
                                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryBlue),
                                    suffixIcon: controller.text.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.clear, size: 20),
                                            onPressed: _clearSelectedPatient,
                                          )
                                        : null,
                                  ),
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Full Name is required' : null,
                                  onChanged: (val) {
                                    if (_selectedPatient != null && _selectedPatient!.name != val) {
                                      setState(() {
                                        _selectedPatient = null;
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
                                          'Existing Patient: ${_selectedPatient!.name}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
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
                                        'ID: #${_selectedPatient!.id.toString().padLeft(4, '0')}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildReadOnlyTreatmentPreview(_selectedPatient!),
                        ],

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
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
                                controller: _ageController,
                                decoration: const InputDecoration(
                                  labelText: 'Age *',
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Required';
                                  if (int.tryParse(val.trim()) == null) return 'Numeric only';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
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
                                  labelText: 'Emergency Contact Number (Optional)',
                                  prefixIcon: Icon(Icons.phone_paused_outlined),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
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
                                value: _selectedDoctor.isNotEmpty ? _selectedDoctor : null,
                                items: doctorList
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                        if (_chargeConsultationFee) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _consultationFee.toStringAsFixed(0),
                                  decoration: InputDecoration(
                                    labelText: 'Consultation Fee (${settings.currencySymbol}) *',
                                    prefixIcon: const Icon(Icons.attach_money),
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
                                  decoration: InputDecoration(
                                    labelText: 'Paid Today (${settings.currencySymbol}) *',
                                    prefixIcon: const Icon(Icons.price_check),
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
                                  items: settings.enabledPaymentMethods
                                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                      .toList(),
                                  onChanged: (val) => setState(() => _paymentMethod = val!),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

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
                                  settings.formatCurrency(_remainingBalance),
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
