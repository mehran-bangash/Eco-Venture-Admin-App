import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/quiz_model.dart';
import '../models/stem_challenge_model.dart';

class FirebaseDatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Node Names defined as constants for safety (Used for Quizzes)
  static const String _adminQuizNode = 'admin_quiz_content';
  static const String _publicQuizNode = 'public_quiz_content';

  // Helper to generate a new key
  String _generateKey() => _database.ref().push().key!;

  // ==================================================
  // VIDEO & STORIES LOGIC (UNCHANGED)
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
  // QUIZ LOGIC (UNCHANGED)
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


  // ==================================================
  // STEM CHALLENGES DATA METHODS (NEW)
  // ==================================================

  // 1. ADD STEM CHALLENGE
  Future<void> addStemChallenge(StemChallengeModel challenge) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final String newKey = _generateKey();

      // Add Meta Data
      final challengeWithMeta = challenge.copyWith(id: newKey, adminId: currentAdminId);
      final Map<String, dynamic> data = challengeWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // Path 1: Private Admin Node
      updates['Admin/$currentAdminId/stem_challenges/${challenge.category}/$newKey'] = data;

      // Path 2: Public User Node
      updates['Public/StemChallenges/${challenge.category}/$newKey'] = data;

      await _database.ref().update(updates);

    } catch (e) {
      throw Exception('Failed to add STEM challenge: $e');
    }
  }

  // 2. UPDATE STEM CHALLENGE
  Future<void> updateStemChallenge(StemChallengeModel challenge) async {
    if (challenge.id == null) throw Exception("Challenge ID is missing");
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }

      // Use existing adminId if present, else current
      final targetAdminId = challenge.adminId ?? currentAdminId;

      if (targetAdminId == null) throw Exception("Target Admin ID missing");

      final challengeWithMeta = challenge.copyWith(adminId: targetAdminId);
      final data = challengeWithMeta.toMap();

      final Map<String, dynamic> updates = {};

      // Path 1: Private Admin Node
      updates['Admin/$targetAdminId/stem_challenges/${challenge.category}/${challenge.id}'] = data;

      // Path 2: Public User Node
      updates['Public/StemChallenges/${challenge.category}/${challenge.id}'] = data;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to update STEM challenge: $e');
    }
  }

  // 3. DELETE STEM CHALLENGE
  Future<void> deleteStemChallenge(String challengeId, String category) async {
    try {
      String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
      if (currentAdminId == null || currentAdminId.isEmpty) {
        currentAdminId = _auth.currentUser?.uid;
      }
      if (currentAdminId == null) throw Exception("Admin ID not found.");

      final Map<String, dynamic> updates = {};

      // Set both paths to null
      updates['Admin/$currentAdminId/stem_challenges/$category/$challengeId'] = null;
      updates['Public/StemChallenges/$category/$challengeId'] = null;

      await _database.ref().update(updates);
    } catch (e) {
      throw Exception('Failed to delete STEM challenge: $e');
    }
  }

  // 4. FETCH: STREAM (Admin side)
  Stream<List<StemChallengeModel>> getStemChallengesStream(String category) async* {
    String? currentAdminId = await SharedPreferencesHelper.instance.getAdminId();
    if (currentAdminId == null || currentAdminId.isEmpty) {
      currentAdminId = _auth.currentUser?.uid;
    }

    if (currentAdminId == null) {
      yield [];
      return;
    }

    // Listen to specific category under Admin node
    // If 'All' is selected, we might need a different strategy or iterate all cats.
    // For now, assuming filtering by specific category path.
    // If category is 'All', you typically fetch all sub-nodes, which is complex in RTDB structure.
    // Best practice: Fetch all if category == 'All', or specific if not.

    Query query;
    if (category == 'All') {
      // Fetching 'All' is tricky because they are nested by category.
      // We will fetch the parent 'stem_challenges' node and flatten it.
      query = _database.ref('Admin/$currentAdminId/stem_challenges');
    } else {
      query = _database.ref('Admin/$currentAdminId/stem_challenges/$category');
    }

    yield* query.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      try {
        final List<StemChallengeModel> challenges = [];
        final Map<dynamic, dynamic> mapData = data as Map<dynamic, dynamic>;

        if (category == 'All') {
          // Structure: { Science: {id1: data}, Technology: {id2: data} }
          mapData.forEach((catKey, catData) {
            final innerMap = catData as Map<dynamic, dynamic>;
            innerMap.forEach((key, value) {
              final challengeMap = Map<String, dynamic>.from(value as Map);
              challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
            });
          });
        } else {
          // Structure: { id1: data, id2: data }
          mapData.forEach((key, value) {
            final challengeMap = Map<String, dynamic>.from(value as Map);
            challenges.add(StemChallengeModel.fromMap(key.toString(), challengeMap));
          });
        }

        return challenges;
      } catch (e) {
        print("Error parsing STEM stream: $e");
        return [];
      }
    });
  }

  // 5. FETCH SINGLE CHALLENGE
  Future<StemChallengeModel?> getSingleStemChallenge(String challengeId, String category) async {
    String? adminUid = await SharedPreferencesHelper.instance.getAdminId();
    adminUid ??= _auth.currentUser?.uid;
    if (adminUid == null) throw Exception("Admin ID missing");

    final snap = await _database
        .ref('Admin/$adminUid/stem_challenges/$category/$challengeId')
        .get();

    if (!snap.exists) return null;

    final data = Map<String, dynamic>.from(snap.value as Map);
    return StemChallengeModel.fromMap(challengeId, data);
  }
}