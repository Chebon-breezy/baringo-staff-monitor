import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapViewScreen extends StatefulWidget {
  final WorkReportModel report;

  const MapViewScreen({Key? key, required this.report}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? mapController;
  LatLng? reportLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() {
    if (widget.report.geoLocation != null) {
      GeoPoint geoPoint = widget.report.geoLocation!;
      reportLocation = LatLng(geoPoint.latitude, geoPoint.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Location')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (reportLocation == null) {
      return _buildErrorWidget('Error: Invalid location data.');
    }

    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          mapController = controller;
        });
      },
      initialCameraPosition: CameraPosition(
        target: reportLocation!,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('reportLocation'),
          position: reportLocation!,
          infoWindow: InfoWindow(
            title: widget.report.task,
            snippet: widget.report.location,
          ),
        ),
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
