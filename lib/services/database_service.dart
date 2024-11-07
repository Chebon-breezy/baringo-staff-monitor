import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User-related methods
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Stream<List<UserModel>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<UserModel>> getAllUsersOnce() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<bool> isUserAdmin(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return (userDoc.data() as Map<String, dynamic>)['isAdmin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Work report-related methods
  Future<void> submitWorkReport(WorkReportModel report) async {
    await _firestore.collection('work_reports').add(report.toMap());
  }

  Stream<List<WorkReportModel>> getWorkReports() {
    return _firestore
        .collection('work_reports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<WorkReportModel>> getUserWorkReports(String userId) {
    return _firestore
        .collection('work_reports')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<WorkReportModel>> getAllWorkReports() {
    return _firestore
        .collection('work_reports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<WorkReportModel>> getAllWorkReportsOnce() async {
    final snapshot = await _firestore
        .collection('work_reports')
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Department-related methods
  Future<List<String>> getAllDepartments() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final workReportsSnapshot =
        await _firestore.collection('work_reports').get();

    Set<String> departments = {};

    for (var doc in usersSnapshot.docs) {
      departments.add(doc.data()['department'] ?? 'Unknown');
    }

    for (var doc in workReportsSnapshot.docs) {
      departments.add(doc.data()['department'] ?? 'Unknown');
    }

    return departments.toList()..sort();
  }

  // Location-related methods
  Future<void> updateUserLocation(String userId, GeoPoint location) async {
    await _firestore.collection('users').doc(userId).update({
      'lastKnownLocation': location,
      'lastLocationUpdate': FieldValue.serverTimestamp(),
    });
  }

  Stream<GeoPoint?> getUserLocation(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['lastKnownLocation'] as GeoPoint?);
  }

  // Analytics methods
  Future<Map<String, int>> getTaskCountByDepartment() async {
    final snapshot = await _firestore.collection('work_reports').get();
    final reports = snapshot.docs
        .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
        .toList();

    Map<String, int> taskCounts = {};
    for (var report in reports) {
      taskCounts[report.department] = (taskCounts[report.department] ?? 0) + 1;
    }

    return taskCounts;
  }

  Future<List<WorkReportModel>> getRecentWorkReports({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('work_reports')
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // You might want to add a method to get users by ward or sub-county
  Stream<List<UserModel>> getUsersByWard(String ward) {
    return _firestore
        .collection('users')
        .where('ward', isEqualTo: ward)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<UserModel>> getUsersBySubCounty(String subCounty) {
    return _firestore
        .collection('users')
        .where('subCounty', isEqualTo: subCounty)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
