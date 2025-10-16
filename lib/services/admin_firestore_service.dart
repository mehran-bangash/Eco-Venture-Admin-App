import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin_model.dart';

class AdminFirestoreService {
  AdminFirestoreService._();
  static final AdminFirestoreService getInstance = AdminFirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'Admins'; // ✅ Consistent collection name

  Future<AdminModel?> createBasicAdminProfile({
    required String aid,
    required String email,
  }) async {
    final docRef = _firestore.collection(_collectionName).doc(aid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'aid': aid,
        'email': email,
        'name': '',
        'imageUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    final newSnap = await docRef.get();
    return AdminModel.fromMap(newSnap.data()!);
  }

  Future<bool> updateAdminName(String aid, String name) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'name': name,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print("Error updating admin name: $e");
      return false;
    }
  }

  Future<bool> updateAdminImage(String aid, String imageUrl) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print("Error updating admin image: $e");
      return false;
    }
  }

  Future<bool> updateAdminEmail(String aid, String email) async {
    try {
      await _firestore.collection(_collectionName).doc(aid).update({
        'email': email,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print("Error updating admin email: $e");
      return false;
    }
  }

  Future<AdminModel?> getAdminProfile(String aid) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(aid).get();
      if (doc.exists) {
        return AdminModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching admin profile: $e");
      return null;
    }
  }
}
