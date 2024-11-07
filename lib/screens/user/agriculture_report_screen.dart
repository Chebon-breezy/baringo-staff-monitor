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

  const AgricultureReportScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AgricultureReportScreen> createState() =>
      _AgricultureReportScreenState();
}

class _AgricultureReportScreenState extends State<AgricultureReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();

  String _selectedSubDepartment = '';
  List<String> _selectedTasks = [];
  String _otherTask = '';
  String _manualLocation = '';
  String? _imagePath;
  bool _isLoading = false;

  final Map<String, List<String>> _subDepartmentTasks = {
    'Directorate Of Crop Production': [
      'Extension Services',
      'Soil and Water Conservation',
      'Irrigation Projects',
      'Crop Research and Development',
    ],
    'Directorate Of Fisheries Development': [
      'Aquaculture Development',
      'Fisheries Extension Services',
      'Fisheries Market Linkages',
      'Fish Stocking',
    ],
    'Directorate Of Livestock Production': [
      'Animal Husbandry Programs',
      'Pasture and Fodder Development',
      'Livestock Markets',
      'Dairy Development',
    ],
    'Directorate of Veterinary Services': [
      'Animal Health Services',
      'Artificial Insemination Programs',
      'Livestock Disease Surveillance',
      'Meat Inspection',
    ],
  };

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agriculture Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Sub-Department'),
                value: _selectedSubDepartment.isNotEmpty
                    ? _selectedSubDepartment
                    : null,
                items: _subDepartmentTasks.keys.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubDepartment = newValue!;
                    _selectedTasks = [];
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a sub-department' : null,
              ),
              const SizedBox(height: 16),
              if (_selectedSubDepartment.isNotEmpty) ...[
                Text('Select Tasks:',
                    style: Theme.of(context).textTheme.titleMedium),
                ...(_subDepartmentTasks[_selectedSubDepartment] ?? [])
                    .map((task) {
                  return CheckboxListTile(
                    title: Text(task),
                    value: _selectedTasks.contains(task),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTasks.add(task);
                        } else {
                          _selectedTasks.remove(task);
                        }
                      });
                    },
                  );
                }).toList(),
                CustomTextField(
                  labelText: 'Other Task',
                  onSaved: (value) => _otherTask = value ?? '',
                ),
              ],
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Location',
                onSaved: (value) => _manualLocation = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Location is required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(
                    _imagePath == null ? 'Take Picture' : 'Retake Picture'),
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Image captured: $_imagePath'),
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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      try {
        Position position = await _locationService.getCurrentPosition();
        final locationInfo = await _locationService.getLocationInfo();

        final tasks = [..._selectedTasks];
        if (_otherTask.isNotEmpty) {
          tasks.add(_otherTask);
        }

        final Map<String, dynamic> additionalData = {
          'selectedTasks': _selectedTasks,
          'otherTask': _otherTask,
        };

        final report = WorkReportModel(
          id: '',
          userId: widget.userId,
          task: tasks.join(', '),
          location: _manualLocation,
          date: DateTime.now(),
          department: 'Agriculture, Livestock, and Fisheries Development',
          subDepartment: _selectedSubDepartment,
          imageUrl: _imagePath,
          ip: locationInfo.ip,
          country: locationInfo.country,
          city: locationInfo.city,
          geoLocation: GeoPoint(position.latitude, position.longitude),
          additionalData: additionalData,
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
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
