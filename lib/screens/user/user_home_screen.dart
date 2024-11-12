import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/screens/user/report_router.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  Future<void> _printReports(BuildContext context,
      List<WorkReportModel> reports, UserModel user) async {
    final pdf = pw.Document();

    // PDF generation logic remains the same
    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Work Reports - ${user.firstName} ${user.surname}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Department: ${user.department}'),
            pw.Text('Sub-Department: ${user.subDepartment ?? "N/A"}'),
            pw.Text('Workstation: ${user.workstation}'),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: ['Task', 'Location', 'Date & Time', 'Status'],
            data: reports
                .map((report) => [
                      report.task,
                      report.location,
                      DateFormat('yyyy-MM-dd HH:mm').format(report.date),
                      'Completed'
                    ])
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'work_reports.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1E26), // Dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1E26),
        elevation: 0,
        title: const Text(
          'BCG Staff(Monitoring and Mapping Tool)',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          StreamBuilder<List<WorkReportModel>>(
            stream: authProvider.currentUser != null
                ? databaseService
                    .getUserWorkReports(authProvider.currentUser!.uid)
                : Stream.value([]),
            builder: (context, reportsSnapshot) {
              return IconButton(
                icon: const Icon(Icons.print, color: Color(0xFF00BFA5)),
                onPressed: reportsSnapshot.hasData &&
                        reportsSnapshot.data!.isNotEmpty
                    ? () async {
                        final user = await databaseService
                            .getUserById(authProvider.currentUser!.uid);
                        if (user != null) {
                          _printReports(context, reportsSnapshot.data!, user);
                        }
                      }
                    : null,
                tooltip: 'Print reports',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFF00BFA5)),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: authProvider.currentUser == null
          ? Center(
              child: Text(
                'Not authenticated. Please log in.',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            )
          : FutureBuilder<UserModel?>(
              future:
                  databaseService.getUserById(authProvider.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00BFA5),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return Center(
                    child: Text(
                      'User data not found. Please try logging out and logging in again.',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user.firstName} ${user.surname}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2D37),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('County', user.county),
                            _buildInfoRow('Sub County', user.subCounty),
                            _buildInfoRow('Ward', user.ward),
                            _buildInfoRow('Department', user.department),
                            if (user.subDepartment != null)
                              _buildInfoRow('Directorate', user.subDepartment!),
                            _buildInfoRow('Workstation', user.workstation),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recent Reports',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<WorkReportModel>>(
                          stream: databaseService.getUserWorkReports(user.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF00BFA5),
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              );
                            }

                            final reports = snapshot.data ?? [];
                            if (reports.isEmpty) {
                              return Center(
                                child: Text(
                                  'No reports submitted yet.',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final report = reports[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A2D37),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.task,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              report.location,
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                            Text(
                                              DateFormat('yyyy-MM-dd HH:mm')
                                                  .format(report.date),
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF00BFA5),
                                      ),
                                    ],
                                  ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportRouter()),
          );
        },
        tooltip: 'Submit Work Report',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
