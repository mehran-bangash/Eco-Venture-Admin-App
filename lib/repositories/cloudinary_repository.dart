import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/firebase_database_service.dart';

class CloudinaryRepository {
  final CloudinaryService _cloudinaryService;
  final FirebaseDatabaseService _databaseService;

  CloudinaryRepository(this._cloudinaryService, this._databaseService);

  // Upload a single file (video or image)
  Future<String?> uploadSingleFile(File file, {required bool isVideo}) {
    return _cloudinaryService.uploadFile(file, isVideo: isVideo);
  }

  // Upload both video + thumbnail together
  Future<Map<String, String?>> uploadVideoAndThumbnail({
    required File videoFile,
    required File thumbnailFile,
  }) async {
    final videoUrl = await _cloudinaryService.uploadFile(videoFile, isVideo: true);
    final thumbnailUrl = await _cloudinaryService.uploadFile(thumbnailFile, isVideo: false);

    return {
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Upload Story data (to Firebase)
  Future<void> saveStoryData({
    required String title,
    required String thumbnailUrl,
    required List<Map<String, String>> pages,
  }) async {
    final Map<String, dynamic> storyData = {
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'pages': pages,
      'uploadedAt': DateTime.now().toIso8601String(),
    };

    await _databaseService.uploadStoryData(storyData);
  }

  // Fetch all stories
  Future<List<Map<String, dynamic>>> getStories() async {
    return await _databaseService.fetchAdminStories();
  }
}
