import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/models/patient.dart';
import '../../dashboard/providers/clinic_provider.dart';
import '../../odontogram/screens/charting_screen.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isNewPatient = true;
  Patient? _selectedPatient;

  String _name = '';
  int _age = 0;
  String _gender = 'Male';
  String _notes = '';
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedTime != null) {
      if (!_isNewPatient && _selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an existing patient.'), backgroundColor: Colors.redAccent)
        );
        return;
      }

      _formKey.currentState!.save();
      
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      try {
        final provider = Provider.of<ClinicProvider>(context, listen: false);
        
        Patient patient;
        if (_isNewPatient) {
          patient = await provider.addPatient(_name, _age, _gender);
        } else {
          patient = _selectedPatient!;
        }
        
        await provider.addAppointment(patient.id!, dateTime, _notes);

        if (!mounted) return;

        if (_isNewPatient) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checkup scheduled successfully!'), backgroundColor: Colors.green)
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ChartingScreen(patient: patient),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          )
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a date/time.'),
          backgroundColor: Colors.redAccent,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Appointment')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: _isNewPatient ? AppTheme.accentCyan : Colors.transparent,
                                foregroundColor: _isNewPatient ? Colors.black : Colors.white,
                                side: const BorderSide(color: AppTheme.accentCyan),
                              ),
                              onPressed: () => setState(() => _isNewPatient = true),
                              child: const Text('New Patient (Checkup)'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: !_isNewPatient ? AppTheme.accentCyan : Colors.transparent,
                                foregroundColor: !_isNewPatient ? Colors.black : Colors.white,
                                side: const BorderSide(color: AppTheme.accentCyan),
                              ),
                              onPressed: () => setState(() => _isNewPatient = false),
                              child: const Text('Existing Patient (Checked)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      Text('Patient Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.accentCyan)),
                      const SizedBox(height: 24),
                      
                      if (_isNewPatient) ...[
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          onSaved: (value) => _name = value!,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                validator: (value) => value == null || int.tryParse(value) == null ? 'Required' : null,
                                onSaved: (value) => _age = int.parse(value!),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                                value: _gender,
                                items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                                onChanged: (v) => setState(() => _gender = v!),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Consumer<ClinicProvider>(
                          builder: (context, provider, child) {
                            if (provider.patients.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No existing patients found. Please register a new patient.', style: TextStyle(color: Colors.redAccent)),
                              );
                            }
                            return DropdownButtonFormField<Patient>(
                              decoration: const InputDecoration(labelText: 'Search / Select Patient', border: OutlineInputBorder()),
                              value: _selectedPatient,
                              items: provider.patients.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (${p.age} y/o)'))).toList(),
                              onChanged: (v) => setState(() => _selectedPatient = v),
                            );
                          }
                        ),
                      ],
                      
                      const SizedBox(height: 32),
                      Text('Appointment Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.accentCyan)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month),
                              label: Text(_selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
                              onPressed: _pickDate,
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedTime == null ? 'Select Time' : _selectedTime!.format(context)),
                              onPressed: _pickTime,
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Notes / Reason', border: OutlineInputBorder()),
                        maxLines: 3,
                        onSaved: (value) => _notes = value ?? '',
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.all(20),
                          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _submit,
                        child: Text(_isNewPatient ? 'Save Checkup' : 'Proceed to Charting'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
