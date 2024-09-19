import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:staff_performance_mapping/models/user_model.dart';
import 'package:staff_performance_mapping/models/work_report_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitWorkReport(WorkReportModel report) async {
    await _firestore.collection('work_reports').add(report.toMap());
  }

  Stream<List<WorkReportModel>> getWorkReports() {
    print('Attempting to fetch work reports');
    return _firestore
        .collection('work_reports')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      print('Received snapshot with ${snapshot.docs.length} documents');
      return snapshot.docs
          .map((doc) => WorkReportModel.fromMap(doc.data(), doc.id))
          .toList();
    }).handleError((error) {
      print('Error in getWorkReports stream: $error');
      return [];
    });
  }

  Future<UserModel?> getUserById(String userId) async {
    DocumentSnapshot doc =
        await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
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

  Future<void> updateUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<bool> isUserAdmin(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return (userDoc.data() as Map<String, dynamic>)?['isAdmin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
}
