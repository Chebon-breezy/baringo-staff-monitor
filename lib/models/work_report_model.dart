import 'package:cloud_firestore/cloud_firestore.dart';

class WorkReportModel {
  final String id;
  final String userId;
  final String task;
  final String location;
  final GeoPoint? geoLocation;
  final DateTime date;
  final String ip;
  final String country;
  final String city;
  final String department;
  final String subDepartment;
  final String? imageUrl;
  final Map<String, dynamic>? additionalData;

  WorkReportModel({
    required this.id,
    required this.userId,
    required this.task,
    required this.location,
    this.geoLocation,
    required this.date,
    required this.ip,
    required this.country,
    required this.city,
    required this.department,
    required this.subDepartment,
    this.imageUrl,
    this.additionalData,
  });

  factory WorkReportModel.fromMap(Map<String, dynamic> data, String id) {
    return WorkReportModel(
      id: id,
      userId: data['userId'] ?? '',
      task: data['task'] ?? '',
      location: data['location'] ?? '',
      geoLocation: data['geoLocation'] as GeoPoint?,
      date: (data['date'] as Timestamp).toDate(),
      ip: data['ip'] ?? '',
      country: data['country'] ?? '',
      city: data['city'] ?? '',
      department: data['department'] ?? '',
      subDepartment: data['subDepartment'] ?? '',
      imageUrl: data['imageUrl'],
      additionalData: data['additionalData'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'task': task,
      'location': location,
      'geoLocation': geoLocation,
      'date': Timestamp.fromDate(date),
      'ip': ip,
      'country': country,
      'city': city,
      'department': department,
      'subDepartment': subDepartment,
      'imageUrl': imageUrl,
      'additionalData': additionalData,
    };
  }
}
