import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/quiz_model.dart';


class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Quiz Node Names defined as constants for safety
  static const String _adminQuizNode = 'admin_quiz_content';
  static const String _publicQuizNode = 'public_quiz_content';

  // Helper to generate a new key
  String _generateKey() => _database.ref().push().key!;

  // ==================================================
  // VIDEO & STORIES LOGIC (UNCHANGED - PERFECT STATE)
  // ==================================================

  /// 1) Upload video metadata under Admin AND Public (atomic update)
  Future<void> uploadVideoDataAndPublic(Map<String, dynamic> videoData) async {
    final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
    final videoId = _generateKey();

    // Build paths
    final adminPath = 'Admin/$adminUid/videos/$videoId';
    final publicPath = 'Public/Videos/$videoId';

    // Admin node data
    final adminData = {
      'id': videoId,
      ...videoData,
    };

    // Public node data (ensure counters AND userLikes exist)
    final publicData = {
      'id': videoId,
      'adminId': adminUid,
      ...videoData,
      'views': 0,
      'likes': 0,
      'dislikes': 0,
      'userLikes': {},  // ✅ This ensures userLikes is created immediately
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
    final adminData = {
      'id': storyId,
      ...storyData,
    };

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
    final updates = <String, dynamic>{
      adminPath: null,
      publicPath: null,
    };
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


  // ==================================================
  // QUIZ LOGIC (UPDATED & FIXED)
  // ==================================================

  // 1. ADD: Create Quiz in BOTH nodes
  Future<void> addQuiz(QuizModel quiz) async {
    try {
      // Try Prefs first, fallback to Auth to ensure we get an ID
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }

      if (currentAdminId == null) throw Exception("Admin ID not found. Please login again.");

      final String newKey = _generateKey();

      // Ensure adminId is attached
      final quizWithMeta = quiz.copyWith(id: newKey, adminId: currentAdminId);
      final Map<String, dynamic> quizData = quizWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // 1. Write to Admin Private Node
      updates['Admin/$currentAdminId/quizzes/${quiz.category}/$newKey'] = quizData;

      // 2. Write to Public User Node
      updates['Public/Quizzes/${quiz.category}/$newKey'] = quizData;

      await _database.ref().update(updates);

    } catch (e) {
      throw Exception('Failed to add quiz: $e');
    }
  }

  // 2. UPDATE: Update Quiz in BOTH nodes
  Future<void> updateQuiz(QuizModel quiz) async {
    if (quiz.id == null) throw Exception("Quiz ID is missing for update");
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }

      // Use the existing adminId on the quiz if available (for editing), else use current
      final targetAdminId = quiz.adminId ?? currentAdminId;

      if (targetAdminId == null) throw Exception("Target Admin ID missing");

      // Ensure the quiz object has the admin ID
      final quizWithMeta = quiz.copyWith(adminId: targetAdminId);
      final quizData = quizWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // 1. Update Admin Node
      updates['Admin/$targetAdminId/quizzes/${quiz.category}/${quiz.id}'] = quizData;

      // 2. Update Public Node
      updates['Public/Quizzes/${quiz.category}/${quiz.id}'] = quizData;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update quiz: $e');
    }
  }

  // 3. DELETE: Remove from BOTH nodes
  Future<void> deleteQuiz(String quizId, String category) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }

      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final Map<String, dynamic> updates = {};

      // 1. Delete from Admin Node (Set to null)
      updates['Admin/$currentAdminId/quizzes/$category/$quizId'] = null;

      // 2. Delete from Public Node (Set to null)
      updates['Public/Quizzes/$category/$quizId'] = null;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // 4. FETCH: STREAM (FIXED MAP TYPE CRASH)
  Stream<List<QuizModel>> getQuizzesStream(String category) async* {
    // 1. Await Admin ID
    String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
    if (currentAdminId == null || currentAdminId.isEmpty) {
      currentAdminId = _auth.currentUser?.uid;
    }

    if (currentAdminId == null) {
      yield []; // Return empty if no ID
      return;
    }

    // 2. Listen to Database
    yield* _database.ref('Admin/$currentAdminId/quizzes/$category').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        // Cast to Map<dynamic, dynamic> first (Firebase default)
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;
        final List<QuizModel> quizzes = [];

        mapData.forEach((key, value) {
          // --- CRITICAL FIX ---
          // Convert the value (which is Map<Object, Object>) to Map<String, dynamic>
          // This prevents the "type cast" error.
          final quizMap = Map<String, dynamic>.from(value as Map);

          quizzes.add(QuizModel.fromMap(key.toString(), quizMap));
        });

        // Sort by Order #
        quizzes.sort((a, b) => a.order.compareTo(b.order));

        return quizzes;
      } catch (e) {
        print("Error parsing quiz stream: $e");
        return [];
      }
    });
  }

  // 5. FETCH SINGLE QUIZ
  Future<QuizModel?> getSingleQuiz(String quizId, String category) async {
    String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
    if (adminUid == null) adminUid = _auth.currentUser?.uid;

    if (adminUid == null) throw Exception("Admin ID missing");

    final snap = await _database
        .ref('Admin/$adminUid/quizzes/$category/$quizId')
        .get();

    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    return QuizModel.fromMap(quizId, data);
  }
}