import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_history_item.dart';

class FirebaseDatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for a specific user
  CollectionReference<Map<String, dynamic>> _userScansRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scan_history');
  }

  Future<void> saveUserScan(String userId, ScanHistoryItem item) async {
    await _userScansRef(userId).doc(item.id).set(item.toMap());
  }

  Future<List<ScanHistoryItem>> getUserScans(String userId) async {
    final snapshot = await _userScansRef(userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => ScanHistoryItem.fromMap(doc.data())).toList();
  }

  Future<void> deleteUserScan(String userId, String scanId) async {
    await _userScansRef(userId).doc(scanId).delete();
  }

  Future<void> deleteAllUserScans(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _userScansRef(userId).get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
}
