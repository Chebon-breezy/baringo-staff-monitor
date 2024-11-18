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

  // New method to get users by designation
  Stream<List<UserModel>> getUsersByDesignation(String designation) {
    return _firestore
        .collection('users')
        .where('designation', isEqualTo: designation)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // New method to get users by department and designation
  Stream<List<UserModel>> getUsersByDepartmentAndDesignation(
      String department, String designation) {
    return _firestore
        .collection('users')
        .where('department', isEqualTo: department)
        .where('designation', isEqualTo: designation)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // New method to get all unique designations
  Future<List<String>> getAllDesignations() async {
    final snapshot = await _firestore.collection('users').get();
    Set<String> designations = {};

    for (var doc in snapshot.docs) {
      String designation = doc.data()['designation'] ?? 'Unknown';
      if (designation.isNotEmpty) {
        designations.add(designation);
      }
    }

    return designations.toList()..sort();
  }

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  // Updated method to include designation in admin checks
  Future<bool> isUserAdmin(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() as Map<String, dynamic>;
      // Check both isAdmin flag and if designation contains "admin" (case insensitive)
      return userData['isAdmin'] == true ||
          (userData['designation'] ?? '').toLowerCase().contains('admin');
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Advanced Analytics Methods

  // New method to get staff count by designation
  Future<Map<String, int>> getStaffCountByDesignation() async {
    final snapshot = await _firestore.collection('users').get();
    Map<String, int> designationCounts = {};

    for (var doc in snapshot.docs) {
      String designation = doc.data()['designation'] ?? 'Unknown';
      designationCounts[designation] =
          (designationCounts[designation] ?? 0) + 1;
    }

    return designationCounts;
  }

  // New method to get staff count by department and designation
  Future<Map<String, Map<String, int>>>
      getStaffCountByDepartmentAndDesignation() async {
    final snapshot = await _firestore.collection('users').get();
    Map<String, Map<String, int>> departmentDesignationCounts = {};

    for (var doc in snapshot.docs) {
      String department = doc.data()['department'] ?? 'Unknown';
      String designation = doc.data()['designation'] ?? 'Unknown';

      departmentDesignationCounts[department] ??= {};
      departmentDesignationCounts[department]![designation] =
          (departmentDesignationCounts[department]![designation] ?? 0) + 1;
    }

    return departmentDesignationCounts;
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

// Method to get users by ward with optional designation filter
  Stream<List<UserModel>> getUsersByWard(String ward, {String? designation}) {
    Query query = _firestore.collection('users').where('ward', isEqualTo: ward);

    if (designation != null) {
      query = query.where('designation', isEqualTo: designation);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Method to get users by sub-county with optional designation filter
  Stream<List<UserModel>> getUsersBySubCounty(String subCounty,
      {String? designation}) {
    Query query =
        _firestore.collection('users').where('subCounty', isEqualTo: subCounty);

    if (designation != null) {
      query = query.where('designation', isEqualTo: designation);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // New method to get performance reports by designation
  Stream<List<WorkReportModel>> getWorkReportsByDesignation(
      String designation) {
    return _firestore
        .collection('work_reports')
        .where('userDesignation', isEqualTo: designation)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}
