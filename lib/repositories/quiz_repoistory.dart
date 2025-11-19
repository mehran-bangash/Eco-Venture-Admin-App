import '../models/quiz_model.dart';
import '../services/firebase_database_service.dart';

class QuizRepository {
  final FirebaseDatabaseService _db;

  QuizRepository(this._db);

  Future<void> createQuiz(QuizModel quiz) async {
    await _db.addQuiz(quiz);
  }

  Future<void> editQuiz(QuizModel quiz) async {
    await _db.updateQuiz(quiz);
  }

  Future<void> removeQuiz(String quizId, String category) async {
    await _db.deleteQuiz(quizId, category);
  }

  Stream<List<QuizModel>> watchQuizzes(String category) {
    return _db.getQuizzesStream(category);
  }

  Future<QuizModel?> getSingleQuiz(String quizId, String category) {
    return _db.getSingleQuiz(quizId, category);
  }
}
