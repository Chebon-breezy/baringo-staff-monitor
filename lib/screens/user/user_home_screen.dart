import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/screens/user/submit_report_screen.dart';
import 'package:staff_performance_mapping/services/database_service.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pushReplacementNamed(
                  '/login'); // Assuming you have a named route for the login screen
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: const Drawer(
          // Drawer content remains the same
          ),
      body: authProvider.currentUser == null
          ? const Center(child: Text('Not authenticated. Please log in.'))
          : FutureBuilder<UserModel?>(
              future:
                  databaseService.getUserById(authProvider.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final user = snapshot.data;
                if (user == null) {
                  return const Center(
                      child: Text(
                          'User data not found. Please try logging out and logging in again.'));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome, ${user.firstName} ${user.surname}!',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          Text('Department: ${user.department}'),
                          Text('County: ${user.county}'),
                          Text('Sub County: ${user.subCounty}'),
                          Text('Ward: ${user.ward}'),
                          Text('Workstation: ${user.workstation}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<WorkReportModel>>(
                        stream: databaseService.getUserWorkReports(user.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          final reports = snapshot.data ?? [];
                          if (reports.isEmpty) {
                            return const Center(
                                child: Text('No reports submitted yet.'));
                          }
                          return ListView.builder(
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return ListTile(
                                title: Text(report.task),
                                subtitle: Text(
                                    '${report.location} - ${report.date.toLocal()}'),
                                trailing: const Icon(Icons.check_circle,
                                    color: Colors.green),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubmitReportScreen()),
          );
        },
        tooltip: 'Submit Work Report',
        child: const Icon(Icons.add),
      ),
    );
  }
}
