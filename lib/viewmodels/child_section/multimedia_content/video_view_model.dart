import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/video_repository.dart';
import '../../../services/firebase_database_service.dart';


class VideoViewModel extends StateNotifier<AsyncValue<void>> {
  final VideoRepository _repository;

  VideoViewModel(this._repository) : super(const AsyncData(null));

  Future<void> saveVideo({
    required String title,
    required String duration,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.saveVideoData(
        title: title,
        duration: duration,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Riverpod providers
final firebaseDatabaseServiceProvider =
Provider((ref) => FirebaseDatabaseService());

final videoRepositoryProvider = Provider(
        (ref) => VideoRepository(ref.read(firebaseDatabaseServiceProvider)));

final videoViewModelProvider =
StateNotifierProvider<VideoViewModel, AsyncValue<void>>(
        (ref) => VideoViewModel(ref.read(videoRepositoryProvider)));
