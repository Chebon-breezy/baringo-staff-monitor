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
  final _scrollController = ScrollController();
  bool _isLoading = false;

  late UserModel _user = UserModel(
    id: '',
    firstName: '',
    middleName: '',
    surname: '',
    idNumber: '',
    phoneNumber: '',
    email: '',
    department: '',
    designation: '',
    county: 'Baringo',
    subCounty: '',
    ward: '',
    workstation: '',
  );

  String _password = '';
  String? _selectedDepartment;
  String? _selectedSubDepartment;
  String? _selectedSubCounty;
  String? _selectedWard;
  bool _obscurePassword = true;

  final List<String> _subCounties = [
    'Baringo Central',
    'Tiaty East',
    'Tiaty West',
    'Eldama Ravine',
    'Baringo South',
    'Mogotio',
    'Baringo North'
  ];

  final Map<String, List<String>> _subCountyWards = {
    'Baringo North': [
      'Barwessa',
      'Saimo Kipsaraman',
      'Saimo Soi',
      'Kabartonjo',
      'Bartabwa'
    ],
    'Tiaty West': ['Tirioko', 'Kolowa', 'Ribkwo'],
    'Tiaty East': ['Silale', 'Tangulbei', 'Loiyamorok', 'Churo/Amaya'],
    'Mogotio': ['Mogotio', 'Emining', 'Kisanana'],
    'Baringo South': ['Mukutani', 'Marigat', 'Mochongoi', 'Ilchamus'],
    'Eldama Ravine': [
      'Lembus',
      'Ravine',
      'Lembus Kwen',
      'Koibatek',
      'Lembus Perkerra',
      'Mumberes/Majimazuri'
    ],
    'Baringo Central': [
      'Kabarnet',
      'Sacho',
      'Tenges',
      'Kapropita',
      'Ewalel Chapchap'
    ],
  };

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Update the color scheme to match Baringo County colors
  final Color primaryGreen = const Color(0xFF2E7D32); // Dark green for headers
  final Color primaryBlue =
      const Color(0xFF1565C0); // Blue for buttons and links
  final Color backgroundColor = Colors.white;
  final Color textColor = const Color(0xFF333333);

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: textColor),
      prefixIcon: Icon(icon, color: primaryGreen),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryGreen, width: 2),
      ),
      filled: true,
      fillColor: backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message,
      {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error
                  : (isSuccess ? Icons.check_circle : Icons.info),
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : (isSuccess ? Colors.green.shade700 : Colors.blue.shade700),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fill in all required fields correctly.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      _formKey.currentState!.save();
      _user = _user.copyWith(
        department: _selectedDepartment,
        subDepartment: _selectedSubDepartment,
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool result = await authProvider.signUp(_user, _password);

      if (result) {
        _showSnackBar('Registration successful!', isSuccess: true);
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        _showSnackBar('Failed to register. Please try again.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Registration error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Staff Registration'),
        backgroundColor: primaryGreen,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryGreen, backgroundColor],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionHeader('Personal Information'),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('First Name*', Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) =>
                            _user = _user.copyWith(firstName: value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: _buildInputDecoration(
                            'Middle Name', Icons.person_outline),
                        onSaved: (value) =>
                            _user = _user.copyWith(middleName: value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('Surname*', Icons.person),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) =>
                            _user = _user.copyWith(surname: value),
                      ),

                      _buildSectionHeader('Contact Information'),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('ID Number*', Icons.badge),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) =>
                            _user = _user.copyWith(idNumber: value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('Phone Number*', Icons.phone),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        keyboardType: TextInputType.phone,
                        onSaved: (value) =>
                            _user = _user.copyWith(phoneNumber: value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('Email*', Icons.email),
                        validator: (value) {
                          if (value!.isEmpty) return 'Required';
                          if (!value.contains('@')) return 'Invalid email';
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (value) =>
                            _user = _user.copyWith(email: value),
                      ),

                      _buildSectionHeader('Location Details'),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration(
                            'Sub-County*', Icons.location_city),
                        value: _selectedSubCounty,
                        items: _subCounties.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCounty = value;
                            _selectedWard = null;
                            _user = _user.copyWith(subCounty: value);
                          });
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedSubCounty != null)
                        DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration('Ward*', Icons.map),
                          value: _selectedWard,
                          items: _subCountyWards[_selectedSubCounty]!
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWard = value;
                              _user = _user.copyWith(ward: value);
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Required' : null,
                        ),

                      _buildSectionHeader('Department Information'),
                      DropdownButtonFormField<String>(
                        decoration: _buildInputDecoration(
                            'Department*', Icons.business),
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
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDepartment != null &&
                          _subDepartments.containsKey(_selectedDepartment))
                        DropdownButtonFormField<String>(
                          decoration: _buildInputDecoration(
                              'Directorate*', Icons.account_tree),
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
                              value == null ? 'Required' : null,
                        ),
                      const SizedBox(height: 16),
                      // Add the new Designation field
                      TextFormField(
                        decoration: _buildInputDecoration(
                            'Designation*', Icons.assignment_ind),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) =>
                            _user = _user.copyWith(designation: value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration:
                            _buildInputDecoration('Workstation*', Icons.work),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) =>
                            _user = _user.copyWith(workstation: value),
                      ),

                      // Keep your existing Security section with updated colors
                      _buildSectionHeader('Security'),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password*',
                          prefixIcon: Icon(Icons.lock, color: primaryGreen),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: primaryGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: primaryGreen, width: 2),
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value!.isEmpty) return 'Required';
                          if (value.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                        onSaved: (value) => _password = value!,
                      ),

                      const SizedBox(height: 32),

                      // Registration button with updated colors
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: _isLoading ? 0 : 4,
                          ),
                          onPressed: _isLoading ? null : _handleRegistration,
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Text(
                                      'Registering...',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Register',
                                  style: TextStyle(
                                    color: backgroundColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '* Required fields',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(color: textColor),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
