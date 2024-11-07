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

  // Activity types based on department reports
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
      appBar: AppBar(title: const Text('Submit Activity Report')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Activity Type'),
                      value: _selectedActivityType.isNotEmpty
                          ? _selectedActivityType
                          : null,
                      items: _activityTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedActivityType = value!),
                      validator: (value) => value == null
                          ? 'Please select an activity type'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Venue',
                      validator: (value) =>
                          value!.isEmpty ? 'Venue is required' : null,
                      onSaved: (value) => _venue = value!,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Activity Description',
                      maxLines: 3,
                      validator: (value) =>
                          value!.isEmpty ? 'Description is required' : null,
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Male Attendance',
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _maleAttendance = int.parse(value!),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      labelText: 'Female Attendance',
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _femaleAttendance = int.parse(value!),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      labelText: 'Youth Attendance',
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                      onSaved: (value) => _youthAttendance = int.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Remarks/Outcomes',
                      maxLines: 2,
                      onSaved: (value) => _remarks = value ?? '',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                          _imagePath == null ? 'Take Photo' : 'Retake Photo'),
                    ),
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Photo captured: $_imagePath'),
                      ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Report',
                      onPressed: _submitReport,
                    ),
                  ],
                ),
              ),
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
