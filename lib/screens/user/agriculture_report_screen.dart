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
  bool _isSubmitting = false;

  // Baringo County color scheme
  static const primaryGreen = Color(0xFF1B5E20); // Dark green
  static const secondaryGreen = Color(0xFF4CAF50); // Lighter green
  static const accentBlue = Color(0xFF1976D2); // Blue for accents
  static const backgroundColor = Colors.white;
  static const surfaceColor = Color(0xFFF5F5F5); // Light grey for cards/inputs

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

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services'),
          backgroundColor: primaryGreen,
        ),
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
            backgroundColor: primaryGreen,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
          backgroundColor: primaryGreen,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    try {
      final position = await _locationService.getCurrentPosition();
      setState(() => _currentPosition = position);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location captured successfully'),
          backgroundColor: primaryGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Widget _buildStyledTextField(
    String label, {
    int? maxLines,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: secondaryGreen.withOpacity(0.5)),
      ),
      child: TextFormField(
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: primaryGreen),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryGreen),
          ),
        ),
        maxLines: maxLines ?? 1,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
        cursorColor: primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Submit Activity Report'),
        backgroundColor: primaryGreen,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: secondaryGreen.withOpacity(0.5)),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Activity Type',
                    labelStyle: TextStyle(color: primaryGreen),
                    border: InputBorder.none,
                  ),
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
                  validator: (value) =>
                      value == null ? 'Please select an activity type' : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildStyledTextField(
                'Venue',
                onSaved: (value) => _venue = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Venue is required' : null,
              ),
              _buildStyledTextField(
                'Activity Description',
                maxLines: 3,
                onSaved: (value) => _description = value!,
                validator: (value) =>
                    value!.isEmpty ? 'Description is required' : null,
              ),
              _buildStyledTextField(
                'Male Attendance',
                keyboardType: TextInputType.number,
                onSaved: (value) => _maleAttendance = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              _buildStyledTextField(
                'Female Attendance',
                keyboardType: TextInputType.number,
                onSaved: (value) => _femaleAttendance = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              _buildStyledTextField(
                'Total Attendance',
                keyboardType: TextInputType.number,
                onSaved: (value) => _youthAttendance = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              _buildStyledTextField(
                'Remarks/Outcomes',
                maxLines: 2,
                onSaved: (value) => _remarks = value ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt,
                          color: Colors.white), // Updated icon color
                      label: Text(
                        _imagePath == null ? 'Take Photo' : 'Retake Photo',
                        style: const TextStyle(
                            color: Colors.white), // Updated text color
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor:
                            Colors.white, // Ensures pressed state is also white
                      ),
                    ),
                  ),
                ],
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Photo captured: $_imagePath',
                    style: const TextStyle(color: primaryGreen),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white, // Ensures text is white
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Add disabled style to maintain white text when button is disabled
                    disabledBackgroundColor: primaryGreen.withOpacity(0.6),
                    disabledForegroundColor: Colors.white.withOpacity(0.7),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, // Loading indicator color
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await _getCurrentLocation();

      if (_currentPosition == null) {
        setState(() => _isSubmitting = false);
        return;
      }

      _formKey.currentState!.save();
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
          const SnackBar(
            content: Text('Report submitted successfully'),
            backgroundColor: primaryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
