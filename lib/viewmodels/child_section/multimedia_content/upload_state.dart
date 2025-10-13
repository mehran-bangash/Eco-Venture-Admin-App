import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class UploadState {
  final bool isLoading;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? error;

  UploadState({
    this.isLoading = false,
    this.videoUrl,
    this.thumbnailUrl,
    this.error,
  });

  UploadState copyWith({
    bool? isLoading,
    String? videoUrl,
    String? thumbnailUrl,
    String? error,
  }) {
    return UploadState(
      isLoading: isLoading ?? this.isLoading,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      error: error ?? this.error,
    );
  }
}
