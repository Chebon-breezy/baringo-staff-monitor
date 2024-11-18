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
  Map<String, UserModel> _userMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
  }

  void _loadUsers() async {
    final users = await _databaseService.getAllUsersOnce();
    setState(() {
      _userMap = {for (var user in users) user.id: user};
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _printUsers(List<UserModel> users) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Text(
          'Staff Performance Mapping - Users List',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
      name: 'users_list.pdf',
    );
  }

  Future<void> _printTasks(List<WorkReportModel> reports) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (context) => pw.Text(
          'Baringo County Government'
          'Reports and Staff Performance Mapping', //Tasks List
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headers: [
              'User Name',
              'Department',
              'Task',
              'Location',
              'Coordinates',
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
                '${report.geoLocation?.latitude ?? "N/A"}, ${report.geoLocation?.longitude ?? "N/A"}',
                DateFormat('yyyy-MM-dd HH:mm').format(report.date),
              ];
            }).toList(),
          ),
        ],
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              'Name:...................................'
              'Date:..................'
              'signature:.............'
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 12),
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
          _buildTasksTable(),
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
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.grey[300],
              ),
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
                defaultColumnWidth: const IntrinsicColumnWidth(),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                    ),
                    children: const [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Name',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Department',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Sub-County',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Email',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Phone Number',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  ...users
                      .map((user) => TableRow(
                            children: [
                              TableCell(
                                child: InkWell(
                                  onTap: () => _navigateToUserDetails(user.id),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '${user.firstName} ${user.middleName} ${user.surname}'),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.department),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.subCounty),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.email),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.phoneNumber),
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
    );
  }

  Widget _buildTasksTable() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: _selectedDepartment,
            items: _departments.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDepartment = newValue!;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<WorkReportModel>>(
            stream: _databaseService.getAllWorkReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final reports = snapshot.data ?? [];
              final filteredReports = _selectedDepartment == 'All'
                  ? reports
                  : reports
                      .where(
                          (report) => report.department == _selectedDepartment)
                      .toList();
              if (filteredReports.isEmpty) {
                return const Center(
                    child: Text(
                        'No tasks available for the selected department.'));
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
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                          ),
                          children: const [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('User Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Department',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Task',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Location',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Coordinates',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Date & Time',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                        ...filteredReports.map((report) {
                          final user = _userMap[report.userId];
                          final userName = user != null
                              ? '${user.firstName} ${user.middleName} ${user.surname}'
                              : 'Unknown User';
                          return TableRow(
                            children: [
                              TableCell(
                                child: InkWell(
                                  onTap: () => _showTaskDetails(report),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(userName),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(report.department),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(report.task),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(report.location),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      '${report.geoLocation?.latitude ?? "N/A"}, ${report.geoLocation?.longitude ?? "N/A"}'),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(DateFormat('yyyy-MM-dd HH:mm')
                                      .format(report.date)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
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
  }

  void _navigateToUserDetails(String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userId: userId),
      ),
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
        return AlertDialog(
          title: const Text('Task Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('User Name: $userName'),
                Text('Task: ${report.task}'),
                Text('Department: ${report.department}'),
                Text('Date: ${report.date.toString()}'),
                Text('Location: ${report.location}'),
                Text(
                    'Coordinates: ${report.geoLocation?.latitude}, ${report.geoLocation?.longitude}'),
                Text('IP: ${report.ip}'),
                Text('Country: ${report.country}'),
                Text('City: ${report.city}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
