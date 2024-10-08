import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/screens/admin/user_details_screen.dart';

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
          _buildUsersDataTable(),
          _buildTasksDataTable(),
        ],
      ),
    );
  }

  Widget _buildUsersDataTable() {
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
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Department')),
                DataColumn(label: Text('Sub-County')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Phone Number')),
              ],
              rows: users
                  .map((user) => DataRow(
                        cells: [
                          DataCell(Text(
                              '${user.firstName} ${user.middleName} ${user.surname}')),
                          DataCell(Text(user.department)),
                          DataCell(Text(user.subCounty)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.phoneNumber)),
                        ],
                        onSelectChanged: (_) => _navigateToUserDetails(user.id),
                      ))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksDataTable() {
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
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('User Name')),
                      DataColumn(label: Text('Department')),
                      DataColumn(label: Text('Task')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Date')),
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
                          DataCell(Text(report.date.toString())),
                        ],
                        onSelectChanged: (_) => _showTaskDetails(report),
                      );
                    }).toList(),
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
