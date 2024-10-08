import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class GenericReportScreen extends StatefulWidget {
  final String userId;
  final String department;

  const GenericReportScreen(
      {Key? key, required this.userId, required this.department})
      : super(key: key);

  @override
  _GenericReportScreenState createState() => _GenericReportScreenState();
}

class _GenericReportScreenState extends State<GenericReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  String _task = '';
  String _location = '';
  String? _imagePath;
  String _additionalNotes = '';

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
      appBar: AppBar(title: Text('${widget.department} Report')),
      body: SingleChildScrollView(
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
                validator: (value) => value!.isEmpty ? 'Enter location' : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                labelText: 'Additional Notes',
                onSaved: (value) => _additionalNotes = value ?? '',
                maxLines: 3,
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      final report = WorkReportModel(
                        id: '',
                        userId: widget.userId,
                        task: _task,
                        location: _location,
                        date: DateTime.now(),
                        department: widget.department,
                        imageUrl: _imagePath,
                        additionalData: {
                          'additionalNotes': _additionalNotes,
                        },
                        ip: '',
                        country: '',
                        city: '',
                        geoLocation: null,
                        subDepartment: '',
                      );
                      await _databaseService.submitWorkReport(report);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Report submitted successfully')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to submit report: $e')),
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
