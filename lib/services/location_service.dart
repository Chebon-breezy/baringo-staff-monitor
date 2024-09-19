// File: lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<LocationInfo> getLocationInfo() async {
    final response = await http.get(Uri.parse('https://ipapi.co/json/'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return LocationInfo(
        ip: data['ip'],
        country: data['country_name'],
        city: data['city'],
      );
    } else {
      throw Exception('Failed to get location info');
    }
  }
}

class LocationInfo {
  final String ip;
  final String country;
  final String city;

  LocationInfo({required this.ip, required this.country, required this.city});
}
