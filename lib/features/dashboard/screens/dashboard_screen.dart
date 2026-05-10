import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../odontogram/screens/charting_screen.dart';
import '../../appointments/screens/add_appointment_screen.dart';
import '../../appointments/screens/appointments_calendar_view.dart';
import '../../patients/screens/patient_profile_screen.dart';
import '../providers/clinic_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Consumer<ClinicProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final todayAppointments = provider.appointments.where((a) {
          final now = DateTime.now();
          return a.dateTime.year == now.year && a.dateTime.month == now.month && a.dateTime.day == now.day;
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Patients', '${provider.patients.length}', Icons.people, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('Today\'s Appointments', '${todayAppointments.length}', Icons.calendar_today, Colors.orange)),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s Appointments', style: Theme.of(context).textTheme.titleLarge),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('New Appointment'),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAppointmentScreen()));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentCyan, foregroundColor: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: todayAppointments.isEmpty 
                    ? const Center(child: Text('No appointments scheduled for today.'))
                    : ListView.separated(
                    itemCount: todayAppointments.length,
                    separatorBuilder: (context, index) => const Divider(color: AppTheme.backgroundDark, height: 1),
                    itemBuilder: (context, index) {
                      final appointment = todayAppointments[index];
                      final patient = provider.getPatientById(appointment.patientId);
                      if (patient == null) return const SizedBox.shrink();

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: AppTheme.backgroundDark, borderRadius: BorderRadius.circular(8)),
                          child: Text(DateFormat('hh:mm a').format(appointment.dateTime), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accentCyan)),
                        ),
                        title: Text(patient.name),
                        subtitle: Text(appointment.notes.isNotEmpty ? appointment.notes : 'Check-up'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCyan.withOpacity(0.2),
                            foregroundColor: AppTheme.accentCyan,
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChartingScreen(patient: patient)));
                          },
                          child: const Text('Open Chart'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildAppointments() {
    return const AppointmentsCalendarView();
  }

  Widget _buildPatients() {
    return const _PatientDatabaseTab();
  }

  Widget _buildSettings() {
    return Center(
      child: Text(
        'Settings\n(Coming Soon)', 
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.textSecondary)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Clinic Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 16),
          const CircleAvatar(backgroundColor: AppTheme.surfaceDark, child: Icon(Icons.person, color: AppTheme.accentCyan)),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Nav for Desktop
          NavigationRail(
            backgroundColor: AppTheme.surfaceDark,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: AppTheme.accentCyan),
            selectedLabelTextStyle: const TextStyle(color: AppTheme.accentCyan),
            unselectedLabelTextStyle: const TextStyle(color: AppTheme.textSecondary),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.calendar_today), label: Text('Appointments')),
              NavigationRailDestination(icon: Icon(Icons.people), label: Text('Patients')),
              NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOverview(),
                _buildAppointments(),
                _buildPatients(),
                _buildSettings(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientDatabaseTab extends StatefulWidget {
  const _PatientDatabaseTab();

  @override
  State<_PatientDatabaseTab> createState() => _PatientDatabaseTabState();
}

class _PatientDatabaseTabState extends State<_PatientDatabaseTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<ClinicProvider>(
      builder: (context, provider, child) {
        final filteredPatients = provider.patients.where((p) {
          return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Patient Database', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search patients...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: filteredPatients.isEmpty 
                  ? const Center(child: Text('No patients found.'))
                  : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return Card(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => PatientProfileScreen(patient: patient)));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircleAvatar(radius: 32, backgroundColor: AppTheme.backgroundDark, child: Icon(Icons.person, size: 32, color: AppTheme.accentCyan)),
                              const SizedBox(height: 12),
                              Text(patient.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('${patient.age} y/o • ${patient.gender}', style: const TextStyle(color: AppTheme.textSecondary)),
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
        );
      }
    );
  }
}

