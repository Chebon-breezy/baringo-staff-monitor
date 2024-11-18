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

  static const Color primaryGreen = Color(0xFF1B5E20); // Dark green
  static const Color secondaryGreen = Color(0xFF4CAF50); // Light green
  static const Color accentBlue = Color(0xFF1976D2); // Blue
  static const Color backgroundColor = Colors.white;
  static const Color cardColor = Color(0xFFF5F5F5); // Light grey for cards

  Future<void> _printReports(BuildContext context,
      List<WorkReportModel> reports, UserModel user) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Baringo County Government',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Work Reports - ${user.firstName} ${user.surname}',
              style: pw.TextStyle(fontSize: 18),
            ),
            pw.Divider(),
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
      name: 'bcg_work_reports.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final databaseService = DatabaseService();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        title: const Text(
          'BCG Staff Monitor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          StreamBuilder<List<WorkReportModel>>(
            stream: authProvider.currentUser != null
                ? databaseService
                    .getUserWorkReports(authProvider.currentUser!.uid)
                : Stream.value([]),
            builder: (context, reportsSnapshot) {
              return IconButton(
                icon: const Icon(Icons.print, color: Colors.white),
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
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      size: 64, color: primaryGreen.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Not authenticated. Please log in.',
                    style: TextStyle(color: primaryGreen.withOpacity(0.7)),
                  ),
                ],
              ),
            )
          : FutureBuilder<UserModel?>(
              future:
                  databaseService.getUserById(authProvider.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'User data not found. Please try logging out and logging in again.',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context)
                            .size
                            .width, // Make container full width
                        padding: const EdgeInsets.all(24),
                        color:
                            primaryGreen, // Remove BoxDecoration and use direct color
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome,',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${user.firstName} ${user.surname}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 2,
                              color: cardColor,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Staff Information',
                                      style: TextStyle(
                                        color: primaryGreen,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInfoRow('County', user.county),
                                    _buildInfoRow('Sub County', user.subCounty),
                                    _buildInfoRow('Ward', user.ward),
                                    _buildInfoRow(
                                        'Department', user.department),
                                    if (user.subDepartment != null)
                                      _buildInfoRow('Sub-Department',
                                          user.subDepartment!),
                                    _buildInfoRow(
                                        'Workstation', user.workstation),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Recent Reports',
                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<List<WorkReportModel>>(
                              stream:
                                  databaseService.getUserWorkReports(user.id),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          primaryGreen),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  );
                                }

                                final reports = snapshot.data ?? [];
                                if (reports.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_outlined,
                                          size: 48,
                                          color: primaryGreen.withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'No reports submitted yet.',
                                          style: TextStyle(
                                            color: primaryGreen,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: reports.length,
                                  itemBuilder: (context, index) {
                                    final report = reports[index];
                                    return Card(
                                      elevation: 1,
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        title: Text(
                                          report.task,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: primaryGreen,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 16,
                                                  color: secondaryGreen,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    report.location,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: secondaryGreen,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(report.date),
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: const Icon(
                                          Icons.check_circle,
                                          color: secondaryGreen,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReportRouter()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Submit Work Report',
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
