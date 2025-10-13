
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/cloudinary_repository.dart';
import '../../../services/cloudinary_service.dart';
import '../../../services/firebase_database_service.dart';
import 'upload_state.dart';
import 'upload_view_model.dart';

final cloudinaryServiceProvider = Provider((ref) => CloudinaryService());
final firebaseDatabaseServiceProvider = Provider((ref) => FirebaseDatabaseService());

//   Pass both dependencies to repository
final cloudinaryRepositoryProvider = Provider(
      (ref) => CloudinaryRepository(
    ref.watch(cloudinaryServiceProvider),
    ref.watch(firebaseDatabaseServiceProvider),
  ),
);

final uploadViewModelProvider =
StateNotifierProvider<UploadViewModel, UploadState>(
      (ref) => UploadViewModel(ref.watch(cloudinaryRepositoryProvider)),
);
