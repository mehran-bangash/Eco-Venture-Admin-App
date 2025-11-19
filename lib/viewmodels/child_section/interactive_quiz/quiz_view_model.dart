import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quiz_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/quiz_repoistory.dart';
import '../../../services/shared_preferences_helper.dart';
import 'quiz_state.dart';

class QuizViewModel extends StateNotifier<QuizState> {
  final QuizRepository _quizRepository;
  final CloudinaryRepository _cloudinaryRepository;

  QuizViewModel(this._quizRepository, this._cloudinaryRepository)
      : super(QuizState());


  Future<String?> getCurrentUserId() async {
    return await SharedPreferencesHelper.instance.getAdminId();
  }
  // ---------------- Process Images ----------------
  Future<QuizModel> _processQuizImages(QuizModel quiz) async {
    // 1. Quiz cover image
    String? finalLevelImageUrl = quiz.imageUrl;

    if (quiz.imageUrl != null && !quiz.imageUrl!.startsWith('http')) {
      if (File(quiz.imageUrl!).existsSync()) {
        finalLevelImageUrl = await _cloudinaryRepository.uploadQuizImage(
          File(quiz.imageUrl!),
          quiz.category,
        );
        if (finalLevelImageUrl == null) {
          throw Exception("Failed to upload Quiz Cover Image.");
        }
      } else {
        finalLevelImageUrl = null;
      }
    }

    // 2. Question images
    List<QuestionModel> updatedQuestions = [];

    for (var q in quiz.questions) {
      String? finalQuestionImageUrl = q.imageUrl;

      if (q.imageUrl != null && !q.imageUrl!.startsWith('http')) {
        if (File(q.imageUrl!).existsSync()) {
          finalQuestionImageUrl = await _cloudinaryRepository.uploadQuizImage(
            File(q.imageUrl!),
            quiz.category,
          );
          if (finalQuestionImageUrl == null) {
            throw Exception("Failed to upload Question Image: ${q.question}");
          }
        } else {
          finalQuestionImageUrl = null;
        }
      }

      updatedQuestions.add(
        q.copyWith(imageUrl: finalQuestionImageUrl),
      );
    }

    return quiz.copyWith(
      imageUrl: finalLevelImageUrl,
      questions: updatedQuestions,
    );
  }

  // ---------------- ADD QUIZ ----------------
  Future<void> addQuiz(QuizModel quiz) async {
    state = state.copyWith(isLoading: true);
    try {
      final quizWithUrls = await _processQuizImages(quiz);
      await _quizRepository.createQuiz(quizWithUrls);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ---------------- UPDATE QUIZ ----------------
  Future<void> updateQuiz(QuizModel quiz) async {
    state = state.copyWith(isLoading: true);
    try {
      final quizWithUrls = await _processQuizImages(quiz);
      await _quizRepository.editQuiz(quizWithUrls);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ---------------- DELETE QUIZ ----------------
  Future<void> deleteQuiz(String quizId, String category) async {
    try {
      await _quizRepository.removeQuiz(quizId, category);
    } catch (e) {
      state = state.copyWith(errorMessage: "Delete failed: ${e.toString()}");
    }
  }

  // Reset success message after UI shows snackbar
  void resetSuccess() {
    state = state.copyWith(isSuccess: false);
  }
}
