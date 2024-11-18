import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/screens/admin/user_details_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;
  String _selectedDepartment = 'All';
  DateTimeRange? _selectedDateRange;
  Map<String, UserModel> _userMap = {};

  final List<String> _departments = [
    'All',
    'Agriculture, Livestock, and Fisheries Development',
    'Education and Vocational Training',
    'Finance and Economic Planning',
    'Industry, Commerce, Tourism, Cooperatives, and Enterprise Development',
    'Lands, Housing, and Urban Development',
    'Roads, Transport, Public Works, and Infrastructure Development',
    'Water, Irrigation, Environment, Natural Resources, and Mining',
    'Youth Affairs, Sports, Gender, Culture, and Social Services',
    'Health Services',
    'Devolution, Public Service, and Administration'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  void _loadUsers() async {
    final users = await _databaseService.getAllUsersOnce();
    setState(() {
      _userMap = {for (var user in users) user.id: user};
    });
  }

  // Add this method near other navigation methods
  void _navigateToUserDetails(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userId: userId),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B5E20), // Dark green
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Future<void> _printUsers(List<UserModel> users) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'BARINGO COUNTY GOVERNMENT',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'STAFF PERFORMANCE MAPPING - USERS LIST',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            cellPadding: const pw.EdgeInsets.all(6),
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 11,
            ),
            headers: [
              'Name',
              'Department',
              'Sub-County',
              'Email',
              'Phone Number'
            ],
            data: users
                .map((user) => [
                      '${user.firstName} ${user.middleName} ${user.surname}',
                      user.department,
                      user.subCounty,
                      user.email,
                      user.phoneNumber,
                    ])
                .toList(),
          ),
        ],
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Name: _________________'),
                pw.Text('Date: _________________'),
                pw.Text('Sign: _________________'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'users_list.pdf',
    );
  }

  Future<void> _printTasks(List<WorkReportModel> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              'BARINGO COUNTY GOVERNMENT',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'STAFF PERFORMANCE MAPPING - TASK REPORTS',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (_selectedDateRange != null)
              pw.Text(
                'Period: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            pw.SizedBox(height: 20),
          ],
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            cellPadding: const pw.EdgeInsets.all(6),
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.grey300,
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(
              fontSize: 9,
            ),
            headers: [
              'User Name',
              'Department',
              'Task',
              'Location',
              'Male',
              'Female',
              'Description',
              'Remarks',
              'Date & Time'
            ],
            data: reports.map((report) {
              final user = _userMap[report.userId];
              final userName = user != null
                  ? '${user.firstName} ${user.middleName} ${user.surname}'
                  : 'Unknown User';
              return [
                userName,
                report.department,
                report.task,
                report.location,
                report.maleAttendance.toString(),
                report.femaleAttendance.toString(),
                report.description,
                report.remarks,
                DateFormat('dd/MM/yyyy HH:mm').format(report.date),
              ];
            }).toList(),
          ),
        ],
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Name: _________________'),
                pw.Text('Date: _________________'),
                pw.Text('Sign: _________________'),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'tasks_list.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              if (_tabController.index == 0) {
                _databaseService
                    .getAllUsersOnce()
                    .then((users) => _printUsers(users));
              } else {
                _databaseService
                    .getAllWorkReportsOnce()
                    .then((reports) => _printTasks(reports));
              }
            },
            tooltip: 'Print current list',
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => authProvider.signOut(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white, // Add this line for selected tab text color
          unselectedLabelColor:
              Colors.white70, // Add this line for unselected tab text color
          tabs: const [
            Tab(text: 'Users'),
            Tab(text: 'Tasks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTable(),
          Column(
            children: [
              _buildFilters(),
              Expanded(child: _buildTasksTable()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _selectedDepartment,
              isExpanded: true,
              hint: const Text('Select Department'),
              items: _departments.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue!;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
            label: Text(
              _selectedDateRange != null
                  ? '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}'
                  : 'Select Date Range',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    return StreamBuilder<List<UserModel>>(
      stream: _databaseService.getAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No users available.'));
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF5F5F5),
                ),
                columnSpacing: 40,
                horizontalMargin: 20,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Sub-County')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                            '${user.firstName} ${user.middleName} ${user.surname}'),
                      ),
                      DataCell(Text(user.department)),
                      DataCell(Text(user.subCounty)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.phoneNumber)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Color(0xFF1976D2)),
                              onPressed: () => _navigateToUserDetails(user.id),
                              tooltip: 'View Details',
                            ),
                            IconButton(
                              icon: const Icon(Icons.map,
                                  color: Color(0xFF1B5E20)),
                              onPressed: () {
                                // TODO: Implement map view for user's latest location
                              },
                              tooltip: 'View Location',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksTable() {
    return StreamBuilder<List<WorkReportModel>>(
      stream: _databaseService.getAllWorkReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allReports = snapshot.data ?? [];
        final filteredReports = allReports.where((report) {
          bool departmentMatch = _selectedDepartment == 'All' ||
              report.department == _selectedDepartment;

          bool dateMatch = true;
          if (_selectedDateRange != null) {
            dateMatch = report.date.isAfter(_selectedDateRange!.start) &&
                report.date.isBefore(
                    _selectedDateRange!.end.add(const Duration(days: 1)));
          }

          return departmentMatch && dateMatch;
        }).toList();

        if (filteredReports.isEmpty) {
          return const Center(
            child: Text('No tasks available for the selected criteria.'),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  const Color(0xFFF5F5F5),
                ),
                columnSpacing: 40,
                horizontalMargin: 20,
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
                columns: const [
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Task')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Male')),
                  DataColumn(label: Text('Female')),
                  DataColumn(label: Text('Total')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Remarks')),
                  DataColumn(label: Text('Date & Time')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: filteredReports.map((report) {
                  final user = _userMap[report.userId];
                  final userName = user != null
                      ? '${user.firstName} ${user.middleName} ${user.surname}'
                      : 'Unknown User';

                  return DataRow(
                    cells: [
                      DataCell(Text(userName)),
                      DataCell(Text(report.department)),
                      DataCell(Text(report.task)),
                      DataCell(Text(report.location)),
                      DataCell(Text(report.maleAttendance.toString())),
                      DataCell(Text(report.femaleAttendance.toString())),
                      DataCell(Text(
                          (report.maleAttendance + report.femaleAttendance)
                              .toString())),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            report.description,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            report.remarks,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(report.date)),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Color(0xFF1976D2)),
                              onPressed: () => _showTaskDetails(report),
                              tooltip: 'View Details',
                            ),
                            if (report.geoLocation != null)
                              IconButton(
                                icon: const Icon(Icons.map,
                                    color: Color(0xFF1B5E20)),
                                onPressed: () {
                                  // TODO: Implement map view for task location
                                },
                                tooltip: 'View on Map',
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTaskDetails(WorkReportModel report) {
    final user = _userMap[report.userId];
    final userName = user != null
        ? '${user.firstName} ${user.middleName} ${user.surname}'
        : 'Unknown User';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    color: Color(0xFF1B5E20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Task Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(
                            'User Information',
                            [
                              _buildDetailRow('Name', userName),
                              _buildDetailRow('Department', report.department),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            'Task Information',
                            [
                              _buildDetailRow('Task', report.task),
                              _buildDetailRow('Location', report.location),
                              _buildDetailRow(
                                'Date & Time',
                                DateFormat('dd/MM/yyyy HH:mm')
                                    .format(report.date),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            'Attendance',
                            [
                              _buildDetailRow(
                                'Male Attendance',
                                report.maleAttendance.toString(),
                              ),
                              _buildDetailRow(
                                'Female Attendance',
                                report.femaleAttendance.toString(),
                              ),
                              _buildDetailRow(
                                'Total Attendance',
                                (report.maleAttendance +
                                        report.femaleAttendance)
                                    .toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildDetailSection(
                            'Additional Information',
                            [
                              _buildDetailRow(
                                  'Description', report.description),
                              _buildDetailRow('Remarks', report.remarks),
                            ],
                          ),
                          if (report.geoLocation != null) ...[
                            const SizedBox(height: 16),
                            _buildDetailSection(
                              'Location Details',
                              [
                                _buildDetailRow(
                                  'Coordinates',
                                  '${report.geoLocation!.latitude}, ${report.geoLocation!.longitude}',
                                ),
                                _buildDetailRow('IP Address', report.ip),
                                _buildDetailRow('Country', report.country),
                                _buildDetailRow('City', report.city),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (report.geoLocation != null)
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.map),
                                  label: const Text('View on Map'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B5E20),
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement map view
                                    Navigator.of(context).pop();
                                  },
                                ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
