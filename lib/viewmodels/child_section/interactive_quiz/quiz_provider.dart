import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quiz_model.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../repositories/quiz_repoistory.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/firebase_database_service.dart';
import 'quiz_view_model.dart';
import 'quiz_state.dart';


// --- LEVEL 1: SERVICES ---

// 👍 FirebaseDatabaseService is now the ONLY service for quiz logic
final firebaseDatabaseServiceProvider =
Provider<FirebaseDatabaseService>((ref) => FirebaseDatabaseService());

// Cloudinary service
final cloudinaryServiceProvider =
Provider<CloudinaryService>((ref) => CloudinaryService());


// --- LEVEL 2: REPOSITORIES ---

// 👍 QuizRepository now depends on FirebaseDatabaseService
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(firebaseDatabaseServiceProvider));
});

// Cloudinary Repository (unchanged)
final cloudinaryRepositoryProvider = Provider<CloudinaryRepository>((ref) {
  return CloudinaryRepository(
    ref.watch(cloudinaryServiceProvider),
    ref.watch(firebaseDatabaseServiceProvider),
  );
});


// --- LEVEL 3: VIEWMODEL ---

final quizViewModelProvider =
StateNotifierProvider<QuizViewModel, QuizState>((ref) {
  return QuizViewModel(
    ref.watch(quizRepositoryProvider),
    ref.watch(cloudinaryRepositoryProvider),
  );
});


// --- LEVEL 4: STREAM OF QUIZZES ---

final quizListStreamProvider =
StreamProvider.family<List<QuizModel>, String>((ref, category) {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.watchQuizzes(category);
});
