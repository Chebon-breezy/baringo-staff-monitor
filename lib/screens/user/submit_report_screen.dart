// File: lib/screens/user/submit_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:staff_performance_mapping/providers/auth_provider.dart';
import 'package:staff_performance_mapping/services/database_service.dart';
import 'package:staff_performance_mapping/services/location_service.dart';
import 'package:staff_performance_mapping/widgets/custom_text_field.dart';
import 'package:staff_performance_mapping/widgets/custom_button.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SubmitReportScreenState createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _task = '';
  String _location = '';
  final LocationService _locationService = LocationService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Work Report')),
      body: Padding(
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
              const SizedBox(height: 24),
              CustomButton(
                text: 'Submit Report',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    try {
                      final position =
                          await _locationService.getCurrentPosition();
                      final geoPoint =
                          GeoPoint(position.latitude, position.longitude);
                      final locationInfo =
                          await _locationService.getLocationInfo();
                      final report = WorkReportModel(
                        id: '',
                        userId: authProvider.currentUser!.uid,
                        task: _task,
                        location: _location,
                        geoLocation: geoPoint,
                        date: DateTime.now(),
                        ip: locationInfo.ip,
                        country: locationInfo.country,
                        city: locationInfo.city,
                      );
                      await _databaseService.submitWorkReport(report);
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Report submitted successfully')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to submit report: $e')),
                        );
                      }
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
