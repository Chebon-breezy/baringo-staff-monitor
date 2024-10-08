import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late UserModel _user = UserModel(
    id: '',
    firstName: '',
    middleName: '',
    surname: '',
    idNumber: '',
    phoneNumber: '',
    email: '',
    department: '',
    county: 'Baringo',
    subCounty: '',
    ward: '',
    workstation: '',
  );
  String _password = '';
  String? _selectedDepartment;
  String? _selectedSubDepartment;

  final List<String> _subCounties = [
    'Baringo Central',
    'Tiaty East',
    'Tiaty West',
    'Eldama Ravine',
    'Baringo South',
    'Mogotio',
    'Baringo North'
  ];

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
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter first name' : null,
                onSaved: (value) => _user = _user.copyWith(firstName: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Middle Name'),
                onSaved: (value) => _user = _user.copyWith(middleName: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Surname'),
                validator: (value) => value!.isEmpty ? 'Enter surname' : null,
                onSaved: (value) => _user = _user.copyWith(surname: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID Number'),
                validator: (value) => value!.isEmpty ? 'Enter ID number' : null,
                onSaved: (value) => _user = _user.copyWith(idNumber: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
                onSaved: (value) => _user = _user.copyWith(phoneNumber: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
                onSaved: (value) => _user = _user.copyWith(email: value),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sub-County'),
                items: _subCounties.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _user = _user.copyWith(subCounty: value);
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a sub-county' : null,
              ),
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
              if (_selectedDepartment != null &&
                  _subDepartments.containsKey(_selectedDepartment))
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Sub-Department'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ward'),
                onSaved: (value) => _user = _user.copyWith(ward: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Workstation'),
                onSaved: (value) => _user = _user.copyWith(workstation: value),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _user = _user.copyWith(
                      department: _selectedDepartment,
                      subDepartment: _selectedSubDepartment,
                    );
                    bool result = await authProvider.signUp(_user, _password);
                    if (result) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to register')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
