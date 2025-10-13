import '../services/firebase_database_service.dart';

class VideoRepository {
  final FirebaseDatabaseService _databaseService;

  VideoRepository(this._databaseService);

  Future<void> saveVideoData({
    required String title,
    required String duration,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    final Map<String, dynamic> videoData = {
      'title': title,
      'duration': duration,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'uploadedAt': DateTime.now().toIso8601String(),
    };

    await _databaseService.uploadVideoData(videoData);
  }

  Future<List<Map<String, dynamic>>> getVideos() async {
    return await _databaseService.fetchAdminVideos();
  }
}
