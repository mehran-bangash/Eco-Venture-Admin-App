import 'dart:io';
import '../services/cloudinary_service.dart';
import '../services/firebase_database_service.dart'; // Retaining the user's import

class CloudinaryRepository {
  final CloudinaryService _cloudinaryService;
  final FirebaseDatabaseService _databaseService;

  CloudinaryRepository(this._cloudinaryService, this._databaseService);

  // --- NEW: Quiz Image Upload ---
  /// Uploads an image for a Quiz Question or Level to Cloudinary,
  /// organized by Admin ID and Category.
  Future<String?> uploadQuizImage(File file, String category) async {
    // This calls the specific function we created in the service layer
    return await _cloudinaryService.uploadQuizImage(file, category: category);
  }
  // -----------------------------

  /// Upload a single file (video or image)
  Future<String?> uploadSingleFile(File file, {required bool isVideo}) {
    return _cloudinaryService.uploadFile(file, isVideo: isVideo);
  }

  /// Upload both video + thumbnail together to Cloudinary
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

  /// Save Video Metadata to Firebase (Admin + Public simultaneously)
  Future<void> saveVideoData({
    required String title,
    required String description,
    required String category,
    required String videoUrl,
    required String thumbnailUrl,
    required String duration,
  }) async {
    final Map<String, dynamic> videoData = {
      'title': title,
      //'description': description,
      //'category': category,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration,
      'uploadedAt': DateTime.now().toIso8601String(),
    };

    // Assuming _databaseService has this method for RTDB fan-out
    // await _databaseService.uploadVideoDataAndPublic(videoData);
  }

  /// Upload Story Metadata to Firebase (Admin + Public simultaneously)
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

    // Assuming _databaseService has this method for RTDB fan-out
    // await _databaseService.uploadStoryDataAndPublic(storyData);
  }

  /// Upload admin profile image to Cloudinary
  Future<String?> uploadProfileImage(File file) async {
    return await _cloudinaryService.uploadProfileImage(file);
  }
}