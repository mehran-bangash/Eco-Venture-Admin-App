import '../../../models/quiz_model.dart';


class QuizState {
  final bool isLoading;
  final List<QuizModel> quizzes;
  final String? errorMessage;
  final bool isSuccess; // For one-time actions like "Saved Successfully"

  QuizState({
    this.isLoading = false,
    this.quizzes = const [],
    this.errorMessage,
    this.isSuccess = false,
  });

  QuizState copyWith({
    bool? isLoading,
    List<QuizModel>? quizzes,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return QuizState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      errorMessage: errorMessage, // Reset error if not passed
      isSuccess: isSuccess ?? false, // Reset success flag by default
    );
  }
}