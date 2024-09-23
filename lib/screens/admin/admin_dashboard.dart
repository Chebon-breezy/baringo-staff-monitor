import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/screens/admin/user_details_screen.dart';
import 'package:intl/intl.dart'; // this import for date formatting

class AdminDashboard extends StatelessWidget {
  final DatabaseService _databaseService = DatabaseService();

  AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => authProvider.signOut(),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _databaseService.isUserAdmin(authProvider.currentUser!.uid),
        builder: (context, adminSnapshot) {
          if (adminSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (adminSnapshot.hasError) {
            return Center(
                child: Text(
                    'Error checking admin status: ${adminSnapshot.error}'));
          }
          if (adminSnapshot.data != true) {
            return const Center(
                child: Text('Error: You do not have admin privileges.'));
          }
          return StreamBuilder<List<WorkReportModel>>(
            stream: _databaseService.getWorkReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                print('Error fetching work reports: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Error: Unable to fetch work reports.'),
                      const SizedBox(height: 10),
                      Text('Details: ${snapshot.error}'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          (context as Element).markNeedsBuild();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              final reports = snapshot.data ?? [];
              if (reports.isEmpty) {
                return const Center(child: Text('No work reports available.'));
              }
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(report.task),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report.location),
                          Text('${report.country}, ${report.city}'),
                          Text(
                              'Geo: ${report.geoLocation?.latitude}, ${report.geoLocation?.longitude}'),
                          Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(report.date)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailsScreen(userId: report.userId),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
