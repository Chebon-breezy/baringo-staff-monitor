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
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
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
      appBar: AppBar(
        title: const Text('User Home'),
        actions: [
          StreamBuilder<List<WorkReportModel>>(
            stream: authProvider.currentUser != null
                ? databaseService
                    .getUserWorkReports(authProvider.currentUser!.uid)
                : Stream.value([]),
            builder: (context, reportsSnapshot) {
              return IconButton(
                icon: const Icon(Icons.print),
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
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await authProvider.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
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
                          Text('County: ${user.county}'),
                          Text('Sub County: ${user.subCounty}'),
                          Text('Ward: ${user.ward}'),
                          Text('Department: ${user.department}'),
                          if (user.subDepartment != null)
                            Text('Directorate: ${user.subDepartment}'),
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
                          return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.grey[300],
                                ),
                                child: Table(
                                  border: TableBorder.all(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                  defaultColumnWidth:
                                      const IntrinsicColumnWidth(),
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                      ),
                                      children: const [
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Task',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Location',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Date & Time',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Status',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ...reports
                                        .map((report) => TableRow(
                                              children: [
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(report.task),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        Text(report.location),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(DateFormat(
                                                            'yyyy-MM-dd HH:mm')
                                                        .format(report.date)),
                                                  ),
                                                ),
                                                TableCell(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green),
                                                  ),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
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
            MaterialPageRoute(builder: (context) => const ReportRouter()),
          );
        },
        tooltip: 'Submit Work Report',
        child: const Icon(Icons.add),
      ),
    );
  }
}
