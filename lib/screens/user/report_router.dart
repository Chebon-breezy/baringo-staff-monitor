import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/screens/user/agriculture_report_screen.dart';
import 'package:staff_performance_mapping/screens/user/water_report_screen.dart';
import 'package:staff_performance_mapping/screens/user/health_report_screen.dart';
import 'package:staff_performance_mapping/screens/user/devolution_report_screen.dart';
import 'package:staff_performance_mapping/screens/user/generic_report_screen.dart';

class ReportRouter extends StatelessWidget {
  const ReportRouter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder<UserModel?>(
      future: authProvider.getCurrentUser(),
      builder: (context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Loading')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(
                child: Text('An error occurred. Please try again.')),
          );
        }

        final user = snapshot.data!;

        switch (user.department) {
          case 'Agriculture, Livestock, and Fisheries Development':
            return AgricultureReportScreen(
              userId: user.id,
              subDepartment:
                  user.subDepartment ?? 'Directorate Of Crop Production',
            );
          case 'Water, Irrigation, Environment, Natural Resources, and Mining':
            return WaterReportScreen(
                userId: user.id, subDepartment: user.subDepartment ?? '');
          case 'Health Services':
            return HealthReportScreen(
                userId: user.id, subDepartment: user.subDepartment ?? '');
          case 'Devolution, Public Service, and Administration':
            return DevolutionReportScreen(
                userId: user.id, subDepartment: user.subDepartment ?? '');
          default:
            return GenericReportScreen(
                userId: user.id, department: user.department);
        }
      },
    );
  }
}
