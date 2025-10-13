
import 'dart:io';
import 'package:eco_venture_admin_portal/viewmodels/child_section/multimedia_content/upload_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/cloudinary_repository.dart';
class UploadViewModel extends StateNotifier<UploadState> {
  final CloudinaryRepository _repository;
  UploadViewModel(this._repository) : super(UploadState());

  //Upload video + thumbnail
  Future<void> uploadVideoAndThumbnail({
    required File videoFile,
    required File thumbnailFile,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final urls = await _repository.uploadVideoAndThumbnail(
        videoFile: videoFile,
        thumbnailFile: thumbnailFile,
      );

      state = state.copyWith(
        isLoading: false,
        videoUrl: urls['videoUrl'],
        thumbnailUrl: urls['thumbnailUrl'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Upload Story (thumbnail + pages)
  Future<void> uploadStory({
    required String title,
    required File thumbnailFile,
    required List<Map<String, String>> pages,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // 1 Upload the story thumbnail using uploadSingleFile()
      final String? thumbnailUrl =
      await _repository.uploadSingleFile(thumbnailFile, isVideo: false);

      // 2 Upload each story page image (if any)
      final List<Map<String, String>> uploadedPages = [];
      for (final page in pages) {
        final text = page['text'] ?? '';
        final localImagePath = page['image'] ?? '';

        if (localImagePath.isNotEmpty) {
          final uploadedImageUrl = await _repository.uploadSingleFile(
            File(localImagePath),
            isVideo: false,
          );
          uploadedPages.add({
            'text': text,
            'image': uploadedImageUrl ?? '',
          });
        } else {
          uploadedPages.add({
            'text': text,
            'image': '',
          });
        }
      }

      // 3 Save the story metadata to Firebase RTDB
      await _repository.saveStoryData(
        title: title,
        thumbnailUrl: thumbnailUrl ?? '',
        pages: uploadedPages,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }



}
