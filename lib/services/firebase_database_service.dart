import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Upload a new video record under the current admin’s node.
  Future<void> uploadVideoData(Map<String, dynamic> videoData) async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final videoId = _database.ref().push().key;

    await _database
        .ref('Admin')
        .child(adminUid)
        .child('videos')
        .child(videoId!)
        .set({
      'id': videoId,
      ...videoData,
    });
  }

  // Upload a new story record under the current admin’s node.
  Future<void> uploadStoryData(Map<String, dynamic> storyData) async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final storyId = _database.ref().push().key;

    await _database
        .ref('Admin')
        .child(adminUid)
        .child('stories')
        .child(storyId!)
        .set({
      'id': storyId,
      ...storyData,
    });
  }

  // Fetch all videos for the current admin.
  Future<List<Map<String, dynamic>>> fetchAdminVideos() async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final snapshot = await _database.ref('Admin/$adminUid/videos').get();

    if (!snapshot.exists) return [];
    final Map data = snapshot.value as Map;
    return data.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Fetch all stories for the current admin.
  Future<List<Map<String, dynamic>>> fetchAdminStories() async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final snapshot = await _database.ref('Admin/$adminUid/stories').get();

    if (!snapshot.exists) return [];
    final Map data = snapshot.value as Map;
    return data.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }
}
