import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/firebase_database_service.dart';

class StoryViewModel extends StateNotifier<AsyncValue<void>> {
  final CloudinaryRepository _repository;

  StoryViewModel(this._repository) : super(const AsyncData(null));

  Future<void> saveStory({
    required String title,
    required String thumbnailUrl,
    required List<Map<String, String>> pages,
  }) async {
    state = const AsyncLoading();
    try {
      await _repository.saveStoryData(
        title: title,
        thumbnailUrl: thumbnailUrl,
        pages: pages,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// 🔹 Riverpod Providers
final firebaseDatabaseServiceProvider =
Provider((ref) => FirebaseDatabaseService());

final cloudinaryRepositoryProvider = Provider(
      (ref) => CloudinaryRepository(
    ref.read(cloudinaryServiceProvider),
    ref.read(firebaseDatabaseServiceProvider),
  ),
);

// Define CloudinaryService provider too
final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());

final storyViewModelProvider =
StateNotifierProvider<StoryViewModel, AsyncValue<void>>(
      (ref) => StoryViewModel(ref.read(cloudinaryRepositoryProvider)),
);
