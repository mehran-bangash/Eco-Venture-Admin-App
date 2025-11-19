import '../services/firebase_database_service.dart';
class VideoRepository {
  final FirebaseDatabaseService _databaseService;

  VideoRepository(this._databaseService);

  // Save video metadata (Admin + Public atomically)
  Future<void> saveVideoData({
    required String title,
    required String duration,
    required String videoUrl,
    required String thumbnailUrl,
    String? description,
    String? category,
  }) async {
    final Map<String, dynamic> videoData = {
      'title': title,
      'duration': duration,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': DateTime.now().toIso8601String(),
      'status': 'published',
    };

    // This writes to both Admin and Public atomically
    await _databaseService.uploadVideoDataAndPublic(videoData);
  }

  // Fetch all public videos (Admin portal might need this)
  Future<List<Map<String, dynamic>>> getPublicVideos() async {
    return await _databaseService.fetchPublicVideos();
  }

  // Delete video (Admin + Public)
  Future<void> deleteVideo({
    required String adminUid,
    required String videoId,
  }) async {
    await _databaseService.deleteVideoAndPublic(
      adminUid: adminUid,
      videoId: videoId,
    );
  }

}
