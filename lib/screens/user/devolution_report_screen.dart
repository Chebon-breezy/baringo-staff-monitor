import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/services/location_service.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DevolutionReportScreen extends StatefulWidget {
  final String userId;
  final String subDepartment;

  const DevolutionReportScreen({
    Key? key,
    required this.userId,
    required this.subDepartment,
  }) : super(key: key);

  @override
  _DevolutionReportScreenState createState() => _DevolutionReportScreenState();
}

class _DevolutionReportScreenState extends State<DevolutionReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  String _task = '';
  String _location = '';
  String? _imagePath;
  String _projectName = '';
  String _stakeholders = '';
  Position? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position position = await _locationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _location = '${position.latitude}, ${position.longitude}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Devolution Report - ${widget.subDepartment}')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Task Description',
                      validator: (value) =>
                          value!.isEmpty ? 'Enter task description' : null,
                      onSaved: (value) => _task = value!,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Location',
                      initialValue: _location,
                      onSaved: (value) {},
                      validator: (value) =>
                          value!.isEmpty ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Project Name',
                      validator: (value) =>
                          value!.isEmpty ? 'Enter project name' : null,
                      onSaved: (value) => _projectName = value!,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Stakeholders Involved',
                      validator: (value) =>
                          value!.isEmpty ? 'Enter stakeholders' : null,
                      onSaved: (value) => _stakeholders = value!,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text(_imagePath == null
                          ? 'Take Picture'
                          : 'Retake Picture'),
                    ),
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Image captured: $_imagePath'),
                      ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Report',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (_currentPosition == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Location data is required')),
                            );
                            return;
                          }
                          try {
                            final locationInfo =
                                await _locationService.getLocationInfo();
                            final report = WorkReportModel(
                              id: '',
                              userId: widget.userId,
                              task: _task,
                              location: _location,
                              date: DateTime.now(),
                              department:
                                  'Devolution, Public Service, and Administration',
                              subDepartment: widget.subDepartment,
                              imageUrl: _imagePath,
                              additionalData: {
                                'projectName': _projectName,
                                'stakeholders': _stakeholders,
                              },
                              ip: locationInfo.ip,
                              country: locationInfo.country,
                              city: locationInfo.city,
                              geoLocation: GeoPoint(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              ),
                            );
                            await _databaseService.submitWorkReport(report);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Report submitted successfully')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed to submit report: $e')),
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
