import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/quiz_model.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper to generate a new key
  String _generateKey() => _database.ref().push().key!;

  /// 1) Upload video metadata under Admin AND Public (atomic update)
  Future<void> uploadVideoDataAndPublic(Map<String, dynamic> videoData) async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final videoId = _generateKey();

    // Build paths
    final adminPath = 'Admin/$adminUid/videos/$videoId';
    final publicPath = 'Public/Videos/$videoId';

    // Admin node data
    final adminData = {'id': videoId, ...videoData};

    // Public node data (ensure counters AND userLikes exist)
    final publicData = {
      'id': videoId,
      'adminId': adminUid,
      ...videoData,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'userLikes': {}, // ✅ This ensures userLikes is created immediately
      'status': videoData['status'] ?? 'published',
    };

    // Atomic update for both Admin and Public nodes
    final updates = <String, dynamic>{
      adminPath: adminData,
      publicPath: publicData,
    };

    await _database.ref().update(updates);
  }

  /// 2) Upload story metadata under Admin AND Public (atomic update)
  Future<void> uploadStoryDataAndPublic(Map<String, dynamic> storyData) async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final storyId = _generateKey();

    final adminPath = 'Admin/$adminUid/stories/$storyId';
    final publicPath = 'Public/Stories/$storyId';

    // Admin node data
    final adminData = {'id': storyId, ...storyData};

    // Public node data
    final publicData = {
      'id': storyId,
      'adminId': adminUid,
      ...storyData,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'userLikes': {}, // ✅ Empty object created immediately
      'status': storyData['status'] ?? 'published',
    };

    // Atomic update
    final updates = <String, dynamic>{
      adminPath: adminData,
      publicPath: publicData,
    };

    await _database.ref().update(updates);
  }

  /// 3) Fetch all public videos (Admin portal)
  Future<List<Map<String, dynamic>>> fetchPublicVideos() async {
    final snapshot = await _database.ref('Public/Videos').get();
    if (!snapshot.exists) return [];
    final Map data = snapshot.value as Map;
    return data.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value);
      map['id'] = e.key;
      return map;
    }).toList();
  }

  /// 4) Delete a video (Admin + Public)
  Future<void> deleteVideoAndPublic({
    required String adminUid,
    required String videoId,
  }) async {
    final adminPath = 'Admin/$adminUid/videos/$videoId';
    final publicPath = 'Public/Videos/$videoId';
    final updates = <String, dynamic>{adminPath: null, publicPath: null};
    await _database.ref().update(updates);
  }

  /// 5) Fetch all public stories (Admin portal)
  Future<List<Map<String, dynamic>>> fetchPublicStories() async {
    final snapshot = await _database.ref('Public/Stories').get();
    if (!snapshot.exists) return [];
    final Map data = snapshot.value as Map;
    return data.entries.map((e) {
      final map = Map<String, dynamic>.from(e.value);
      map['id'] = e.key;
      return map;
    }).toList();
  }
// ---------------- QUIZ FUNCTIONS ----------------

  /// 1. ADD QUIZ
  Future<void> addQuiz(QuizModel quiz) async {
    try {
      String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
      if (adminUid == null) throw Exception("Admin ID missing");

      final quizId = _generateKey();
      final quizWithMeta = quiz.copyWith(id: quizId, adminId: adminUid);
      final data = quizWithMeta.toMap();

      final adminPath = 'Admin/$adminUid/quizzes/${quiz.category}/$quizId';
      final publicPath = 'Public/Quizzes/${quiz.category}/$quizId';

      await _database.ref().update({
        adminPath: data,
        publicPath: data,
      });
    } catch (e) {
      throw Exception("Failed to add quiz: $e");
    }
  }

  /// 2. UPDATE QUIZ
  Future<void> updateQuiz(QuizModel quiz) async {
    if (quiz.id == null) throw Exception("Quiz ID missing");

    try {
      String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
      if (adminUid == null) throw Exception("Admin ID missing");

      final quizWithMeta = quiz.adminId == null
          ? quiz.copyWith(adminId: adminUid)
          : quiz;

      final data = quizWithMeta.toMap();

      final adminPath = 'Admin/$adminUid/quizzes/${quiz.category}/${quiz.id}';
      final publicPath = 'Public/Quizzes/${quiz.category}/${quiz.id}';

      await _database.ref().update({
        adminPath: data,
        publicPath: data,
      });
    } catch (e) {
      throw Exception("Failed to update quiz: $e");
    }
  }

  /// 3. DELETE QUIZ
  Future<void> deleteQuiz(String quizId, String category) async {
    try {
      String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
      if (adminUid == null) throw Exception("Admin ID missing");

      final adminPath = 'Admin/$adminUid/quizzes/$category/$quizId';
      final publicPath = 'Public/Quizzes/$category/$quizId';

      await _database.ref().update({
        adminPath: null,
        publicPath: null,
      });
    } catch (e) {
      throw Exception("Failed to delete quiz: $e");
    }
  }

  /// 4. REALTIME QUIZ STREAM
  Stream<List<QuizModel>> getQuizzesStream(String category) async* {
    String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
    if (adminUid == null) throw Exception("Admin ID missing");

    yield* _database
        .ref('Admin/$adminUid/quizzes/$category')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) return [];

      final list = data.entries.map((e) {
        return QuizModel.fromMap(e.key, Map<String, dynamic>.from(e.value));
      }).toList();

      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    });
  }

  /// 5. FETCH SINGLE QUIZ
  Future<QuizModel?> getSingleQuiz(String quizId, String category) async {
    String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
    if (adminUid == null) throw Exception("Admin ID missing");

    final snap = await _database
        .ref('Admin/$adminUid/quizzes/$category/$quizId')
        .get();

    if (!snap.exists) return null;

    return QuizModel.fromMap(
      quizId,
      Map<String, dynamic>.from(snap.value as Map),
    );
  }

}
