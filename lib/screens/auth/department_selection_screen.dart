import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/screens/user/user_home_screen.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  final UserModel user;

  const DepartmentSelectionScreen({Key? key, required this.user})
      : super(key: key);

  @override
  _DepartmentSelectionScreenState createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  String? _selectedDepartment;
  String? _selectedSubDepartment;

  final List<String> _departments = [
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

  final Map<String, List<String>> _subDepartments = {
    'Agriculture, Livestock, and Fisheries Development': [
      'Directorate Of Crop Production',
      'Directorate Of Fisheries Development',
      'Directorate Of Livestock Production',
      'Directorate of Veterinary Services'
    ],
    'Water, Irrigation, Environment, Natural Resources, and Mining': [
      'County Irrigation Development Unit (CIDU)',
      'Climate Change GRM',
      'County Water Boards',
      'Water And Sanitation'
    ],
    'Health Services': [
      'Preventive And Promotive Health Directorate',
      'Health Planning And Administration Directorate',
      'Medical Services Directorate'
    ],
    'Devolution, Public Service, and Administration': [
      'Directorate Of Human Resource',
      'Directorate Of Communication',
      'Directorate Of Disaster Management',
      'ICT And E-Government Directorate',
      'The County Administration'
    ],
  };

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Department')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Department'),
              value: _selectedDepartment,
              items: _departments.map((String department) {
                return DropdownMenuItem<String>(
                  value: department,
                  child: Text(department),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartment = newValue;
                  _selectedSubDepartment = null;
                });
              },
              validator: (value) =>
                  value == null ? 'Select a department' : null,
            ),
            const SizedBox(height: 16),
            if (_selectedDepartment != null &&
                _subDepartments.containsKey(_selectedDepartment))
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sub-Department'),
                value: _selectedSubDepartment,
                items: _subDepartments[_selectedDepartment]!
                    .map((String subDepartment) {
                  return DropdownMenuItem<String>(
                    value: subDepartment,
                    child: Text(subDepartment),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubDepartment = newValue;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a sub-department' : null,
              ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Save and Continue',
              onPressed: () async {
                if (_selectedDepartment != null) {
                  final updatedUser = widget.user.copyWith(
                    department: _selectedDepartment,
                    subDepartment: _selectedSubDepartment,
                  );
                  await authProvider.updateUserProfile(updatedUser);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserHomeScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a department')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
