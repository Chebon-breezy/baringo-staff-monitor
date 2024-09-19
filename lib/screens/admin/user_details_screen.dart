import 'package:flutter/material.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/screens/admin/map_view_screen.dart';

class UserDetailsScreen extends StatelessWidget {
  final String userId;
  final DatabaseService _databaseService = DatabaseService();

  UserDetailsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Details')),
      body: FutureBuilder<UserModel?>(
        future: _databaseService.getUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${user.firstName} ${user.surname}',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('ID Number: ${user.idNumber}'),
                Text('Phone: ${user.phoneNumber}'),
                Text('Email: ${user.email}'),
                Text('Department: ${user.department}'),
                Text('County: ${user.county}'),
                Text('Sub County: ${user.subCounty}'),
                Text('Ward: ${user.ward}'),
                Text('Workstation: ${user.workstation}'),
                const SizedBox(height: 24),
                Text('Work Reports',
                    style: Theme.of(context).textTheme.titleLarge),
                Expanded(
                  child: StreamBuilder<List<WorkReportModel>>(
                    stream: _databaseService.getUserWorkReports(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      final reports = snapshot.data ?? [];
                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ListTile(
                            title: Text(report.task),
                            subtitle: Text(
                                '${report.location} - ${report.date.toString()}'),
                            trailing: const Icon(Icons.map),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MapViewScreen(report: report),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
