import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme.dart';
import '../../../../core/models/doctor.dart';
import '../../../../core/models/secretary.dart';
import '../../../dashboard/providers/clinic_provider.dart';
import '../../../dashboard/providers/settings_provider.dart';

class StaffSettingsScreen extends StatefulWidget {
  const StaffSettingsScreen({Key? key}) : super(key: key);

  @override
  State<StaffSettingsScreen> createState() => _StaffSettingsScreenState();
}

class _StaffSettingsScreenState extends State<StaffSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDoctorDialog(BuildContext context, [Doctor? doctor]) {
    final nameCtrl = TextEditingController(text: doctor?.name ?? '');
    final specialtyCtrl = TextEditingController(text: doctor?.specialty ?? 'General Dentist');
    final phoneCtrl = TextEditingController(text: doctor?.phone ?? '');
    final emailCtrl = TextEditingController(text: doctor?.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(doctor == null ? 'Add Doctor' : 'Edit Doctor'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialtyCtrl,
                decoration: const InputDecoration(labelText: 'Specialty *', prefixIcon: Icon(Icons.medical_services)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final provider = Provider.of<ClinicProvider>(context, listen: false);
              if (doctor == null) {
                await provider.addDoctor(
                  Doctor(
                    name: nameCtrl.text.trim(),
                    specialty: specialtyCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                  ),
                );
              } else {
                await provider.updateDoctor(
                  doctor.copyWith(
                    name: nameCtrl.text.trim(),
                    specialty: specialtyCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                  ),
                );
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSecretaryDialog(BuildContext context, [Secretary? secretary]) {
    final nameCtrl = TextEditingController(text: secretary?.name ?? '');
    final phoneCtrl = TextEditingController(text: secretary?.phone ?? '');
    final usernameCtrl = TextEditingController(text: secretary?.username ?? '');
    final passwordCtrl = TextEditingController(text: secretary?.password ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(secretary == null ? 'Add Secretary' : 'Edit Secretary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username *', prefixIcon: Icon(Icons.account_circle)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password *', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || usernameCtrl.text.trim().isEmpty) return;
              final provider = Provider.of<ClinicProvider>(context, listen: false);
              if (secretary == null) {
                await provider.addSecretary(
                  Secretary(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                  ),
                );
              } else {
                await provider.updateSecretary(
                  secretary.copyWith(
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    username: usernameCtrl.text.trim(),
                    password: passwordCtrl.text.trim(),
                  ),
                );
              }
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('Staff Management')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: const Icon(Icons.medical_services), text: settings.translate('Doctors')),
            Tab(icon: const Icon(Icons.support_agent), text: settings.translate('Secretaries')),
          ],
        ),
      ),
      body: Consumer<ClinicProvider>(
        builder: (context, clinic, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // TAB 1: DOCTORS LIST
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          settings.translate('Clinic Doctors'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(settings.translate('Add Doctor')),
                          onPressed: () => _showDoctorDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: clinic.doctors.isEmpty
                          ? Center(child: Text(settings.translate('No doctors configured.')))
                          : ListView.builder(
                              itemCount: clinic.doctors.length,
                              itemBuilder: (context, index) {
                                final doc = clinic.doctors[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                      child: const Icon(Icons.person, color: AppTheme.primaryBlue),
                                    ),
                                    title: Text(doc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${doc.specialty} • ${doc.phone}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                                          onPressed: () => _showDoctorDialog(context, doc),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => clinic.deleteDoctor(doc.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // TAB 2: SECRETARIES LIST
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          settings.translate('Clinic Secretaries'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(settings.translate('Add Secretary')),
                          onPressed: () => _showSecretaryDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: clinic.secretaries.isEmpty
                          ? Center(child: Text(settings.translate('No secretaries configured.')))
                          : ListView.builder(
                              itemCount: clinic.secretaries.length,
                              itemBuilder: (context, index) {
                                final sec = clinic.secretaries[index];
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.teal.withOpacity(0.1),
                                      child: const Icon(Icons.support_agent, color: Colors.teal),
                                    ),
                                    title: Text(sec.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('User: ${sec.username} • Phone: ${sec.phone}'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
                                          onPressed: () => _showSecretaryDialog(context, sec),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => clinic.deleteSecretary(sec.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
