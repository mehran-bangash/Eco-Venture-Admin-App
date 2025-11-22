import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/stem_challenge_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/stem_challenges_repository.dart';
import 'stem_challenges_state.dart';

class StemChallengesViewModel extends StateNotifier<StemChallengesState> {
  final StemChallengesRepository _repository;
  final CloudinaryRepository _cloudinaryRepository;

  StemChallengesViewModel(this._repository, this._cloudinaryRepository)
      : super(StemChallengesState());

  // --- HELPER: Upload Image if needed ---
  Future<StemChallengeModel> _processImage(StemChallengeModel challenge) async {
    String? finalImageUrl = challenge.imageUrl;

    // Check if imageUrl exists AND is a local file path (not an HTTP link)
    if (challenge.imageUrl != null && !challenge.imageUrl!.startsWith('http')) {
      final file = File(challenge.imageUrl!);
      if (file.existsSync()) {
        finalImageUrl = await _cloudinaryRepository.uploadStemImage(
          file,
          challenge.category, // Organize folder by category
        );
        if (finalImageUrl == null) {
          throw Exception("Failed to upload Challenge Image.");
        }
      } else {
        finalImageUrl = null; // File missing, clear it
      }
    }

    // Return copy with proper URL
    return challenge.copyWith(imageUrl: finalImageUrl);
  }

  // --- ACTIONS ---

  // 1. ADD
  Future<void> addChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      // Step A: Upload Image
      final challengeWithUrl = await _processImage(challenge);

      // Step B: Save to Firebase
      await _repository.addChallenge(challengeWithUrl);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 2. UPDATE
  Future<void> updateChallenge(StemChallengeModel challenge) async {
    state = state.copyWith(isLoading: true);
    try {
      // Step A: Upload Image (only if changed to a local file)
      final challengeWithUrl = await _processImage(challenge);

      // Step B: Update in Firebase
      await _repository.updateChallenge(challengeWithUrl);

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // 3. DELETE
  Future<void> deleteChallenge(String challengeId, String category) async {
    try {
      await _repository.deleteChallenge(challengeId, category);
      // No loading state needed for delete usually, creates smoother UI
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: ${e.toString()}");
    }
  }

  // Reset success flag after UI handles it (e.g. showing Snackbar)
  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}