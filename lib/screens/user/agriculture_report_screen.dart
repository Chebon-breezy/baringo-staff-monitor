import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/services/location_service.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgricultureReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const AgricultureReportScreen({
    Key? key,
    required this.userId,
    required this.subDepartment,
  }) : super(key: key);

  @override
  _AgricultureReportScreenState createState() =>
      _AgricultureReportScreenState();
}

class _AgricultureReportScreenState extends State<AgricultureReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();

  String _selectedActivityType = '';
  String _venue = '';
  String _description = '';
  int _maleAttendance = 0;
  int _femaleAttendance = 0;
  int _youthAttendance = 0;
  String _remarks = '';
  String? _imagePath;
  Position? _currentPosition;
  bool _isLoading = false;

  final List<String> _activityTypes = [
    'Individual farm visits',
    'Group visits',
    'Trainings',
    'Barazas',
    'Input Distribution',
    'Field days/Exhibitions',
    'Demonstration',
    'Crop damage assessment',
    'Information desk',
    'Market survey',
    'Plant clinics',
    'Staff meeting',
    'Farm business planning',
    'Soil sampling',
    'Distribution of inputs',
    'Project site visits',
    'Laying of soil conservation structures'
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      Position position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Submit Activity Report'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00BFA5)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Activity Type',
                          labelStyle: TextStyle(color: Color(0xFF00BFA5)),
                          border: InputBorder.none,
                        ),
                        dropdownColor: const Color(0xFF2D2D2D),
                        style: const TextStyle(color: Colors.white),
                        value: _selectedActivityType.isNotEmpty
                            ? _selectedActivityType
                            : null,
                        items: _activityTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _selectedActivityType = value!),
                        validator: (value) => value == null
                            ? 'Please select an activity type'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      'Venue',
                      onSaved: (value) => _venue = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Venue is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      'Activity Description',
                      maxLines: 3,
                      onSaved: (value) => _description = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      'Male Attendance',
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _maleAttendance = int.parse(value!),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildStyledTextField(
                      'Female Attendance',
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _femaleAttendance = int.parse(value!),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    _buildStyledTextField(
                      'Total Attendance',
                      keyboardType: TextInputType.number,
                      onSaved: (value) => _youthAttendance = int.parse(value!),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildStyledTextField(
                      'Remarks/Outcomes',
                      maxLines: 2,
                      onSaved: (value) => _remarks = value ?? '',
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(
                            _imagePath == null ? 'Take Photo' : 'Retake Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D2D2D),
                          foregroundColor: const Color(0xFF00BFA5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Photo captured: $_imagePath',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        child: const Text('Submit Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00BFA5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStyledTextField(
    String label, {
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF00BFA5)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        cursorColor: const Color(0xFF00BFA5),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate() && _currentPosition != null) {
      _formKey.currentState!.save();

      try {
        final locationInfo = await _locationService.getLocationInfo();

        final report = WorkReportModel(
          id: '',
          userId: widget.userId,
          task: _selectedActivityType,
          location: _venue,
          geoLocation:
              GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
          date: DateTime.now(),
          department: 'Agriculture, Livestock, and Fisheries Development',
          subDepartment: widget.subDepartment,
          imageUrl: _imagePath,
          ip: locationInfo.ip,
          country: locationInfo.country,
          city: locationInfo.city,
          additionalData: {
            'description': _description,
            'maleAttendance': _maleAttendance,
            'femaleAttendance': _femaleAttendance,
            'youthAttendance': _youthAttendance,
            'totalAttendance':
                _maleAttendance + _femaleAttendance + _youthAttendance,
            'remarks': _remarks,
          },
        );

        await _databaseService.submitWorkReport(report);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Report submitted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit report: $e')),
          );
        }
      }
    } else if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Waiting for location data. Please try again.')),
      );
    }
  }
}
