import 'dart:io';
import 'package:eco_venture_admin_portal/core/constants/app_colors.dart';
import 'package:eco_venture_admin_portal/services/cloudinary_service.dart';
import 'package:eco_venture_admin_portal/repositories/cloudinary_repository.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/multimedia_content/video_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../services/firebase_database_service.dart';


class AddVideoScreen extends ConsumerStatefulWidget {
  const AddVideoScreen({super.key});

  @override
  ConsumerState<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends ConsumerState<AddVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _thumbnailFile;
  File? _videoFile;
  bool _isUploading = false;

  Future<void> _pickThumbnail() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _thumbnailFile = File(picked.path));
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _videoFile = File(picked.path));
    }
  }

  Future<void> _upload() async {
    if (_thumbnailFile == null || _videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both thumbnail and video')),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Step 1: Upload to Cloudinary
      final cloudinaryRepo = CloudinaryRepository(
        CloudinaryService(),
        FirebaseDatabaseService(),
      );

      final uploadResult = await cloudinaryRepo.uploadVideoAndThumbnail(
        videoFile: _videoFile!,
        thumbnailFile: _thumbnailFile!,
      );

      final videoUrl = uploadResult['videoUrl'];
      final thumbnailUrl = uploadResult['thumbnailUrl'];

      if (videoUrl == null || thumbnailUrl == null) {
        throw Exception('Cloudinary upload failed.');
      }

      // Step 2: Save metadata to Firebase Realtime Database
      await ref.read(videoViewModelProvider.notifier).saveVideo(
        title: _titleController.text.trim(),
        duration: _durationController.text.trim(),
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully!')),
      );

      _titleController.clear();
      _durationController.clear();
      setState(() {
        _thumbnailFile = null;
        _videoFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(videoViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.goNamed('multiMediaContent'),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: Text(
          "Add New Video",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Video Title",
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Thumbnail Picker
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 20.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _thumbnailFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Upload Thumbnail"),
                  ],
                )
                    : Image.file(_thumbnailFile!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 3.h),

            // Video Picker
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 15.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _videoFile == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Upload Video"),
                  ],
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text("Video Selected"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Duration field
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: "Video Duration (e.g. 3:45)",
                prefixIcon: const Icon(Icons.timer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 5.h),

            // Upload button
            Center(
              child: SizedBox(
                width: 80.w,
                height: 7.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    "Upload Video",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.background,
                    ),
                  ),
                  onPressed: _isUploading ? null : _upload,
                ),
              ),
            ),

            // Error UI from viewmodel
            if (uploadState.hasError)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  "Error: ${uploadState.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
