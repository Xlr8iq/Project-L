import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../odontogram/screens/charting_screen.dart';
import '../../appointments/screens/add_appointment_screen.dart';
import '../../appointments/screens/appointments_calendar_view.dart';
import '../../patients/screens/patient_profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../providers/clinic_provider.dart';
import '../providers/settings_provider.dart';

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
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return Consumer2<ClinicProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
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
              Text(
                settings.translate('Overview'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      settings.translate('Total Patients'),
                      '${provider.patients.length}',
                      Icons.people,
                      AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      settings.translate('Today\'s Appointments'),
                      '${todayAppointments.length}',
                      Icons.calendar_today,
                      Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.translate('Today\'s Appointments'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(settings.translate('New Appointment')),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddAppointmentScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  child: todayAppointments.isEmpty 
                    ? Center(
                        child: Text(
                          settings.translate('No appointments scheduled for today.'),
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: todayAppointments.length,
                        separatorBuilder: (context, index) => const Divider(color: AppTheme.borderLight, height: 1),
                        itemBuilder: (context, index) {
                          final appointment = todayAppointments[index];
                          final patient = provider.getPatientById(appointment.patientId);
                          if (patient == null) return const SizedBox.shrink();

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('hh:mm a').format(appointment.dateTime),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                            title: Text(
                              patient.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              appointment.notes.isNotEmpty ? appointment.notes : settings.translate('Check-up'),
                              style: const TextStyle(color: AppTheme.textSecondary),
                            ),
                            trailing: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ChartingScreen(patient: patient)),
                                );
                              },
                              child: Text(settings.translate('Open Chart')),
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
    return const SettingsScreen();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(settings.translate('Dental Clinic')),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar Nav for Desktop
          NavigationRail(
            backgroundColor: Colors.white,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(icon: const Icon(Icons.dashboard), label: Text(settings.translate('Overview'))),
              NavigationRailDestination(icon: const Icon(Icons.calendar_today), label: Text(settings.translate('Appointments'))),
              NavigationRailDestination(icon: const Icon(Icons.people), label: Text(settings.translate('Patients'))),
              NavigationRailDestination(icon: const Icon(Icons.settings), label: Text(settings.translate('Settings'))),
            ],
          ),
          const VerticalDivider(width: 1, color: AppTheme.borderLight),
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
    final settings = context.watch<SettingsProvider>();
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
                  Text(
                    settings.translate('Patient Database'),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: settings.translate('Search patients...'),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: filteredPatients.isEmpty 
                  ? Center(
                      child: Text(
                        settings.translate('No patients found.'),
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
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
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => PatientProfileScreen(patient: patient)),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                                    child: const Icon(Icons.person, size: 28, color: AppTheme.primaryBlue),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    patient.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${patient.age} y/o • ${patient.gender}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
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
