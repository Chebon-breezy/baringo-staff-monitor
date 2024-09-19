import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';

class MapViewScreen extends StatefulWidget {
  final WorkReportModel report;

  const MapViewScreen({Key? key, required this.report}) : super(key: key);

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _checkLocationData();
  }

  void _checkLocationData() {
    print('Checking location data:');
    print('GeoLocation: ${widget.report.geoLocation}');
    print('Latitude: ${widget.report.geoLocation?.latitude}');
    print('Longitude: ${widget.report.geoLocation?.longitude}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Location')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.report.geoLocation == null) {
      return _buildErrorWidget('Error: GeoLocation is null.');
    }

    final double? lat = widget.report.geoLocation?.latitude;
    final double? lng = widget.report.geoLocation?.longitude;

    if (lat == null || lng == null) {
      return _buildErrorWidget('Error: Invalid latitude or longitude.');
    }

    return FutureBuilder<bool>(
      future: Future.delayed(const Duration(milliseconds: 500), () => true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _buildErrorWidget('Error initializing map: ${snapshot.error}');
        }
        return _buildMap(LatLng(lat, lng));
      },
    );
  }

  Widget _buildMap(LatLng reportLocation) {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          mapController = controller;
          _isMapReady = true;
        });
      },
      initialCameraPosition: CameraPosition(
        target: reportLocation,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('reportLocation'),
          position: reportLocation,
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
