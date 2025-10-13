import 'dart:io';
import 'package:eco_venture_admin_portal/repositories/cloudinary_repository.dart';
import 'package:eco_venture_admin_portal/services/cloudinary_service.dart';
import 'package:eco_venture_admin_portal/services/firebase_database_service.dart';
import 'package:eco_venture_admin_portal/viewmodels/child_section/multimedia_content/story_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class AddStoryScreen extends ConsumerStatefulWidget {
  const AddStoryScreen({super.key});

  @override
  ConsumerState<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends ConsumerState<AddStoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, String>> _storyPages = [];
  File? _thumbnailFile;

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickThumbnail() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _thumbnailFile = File(picked.path));
    }
  }

  Future<void> _pickPageImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _storyPages[index]["image"] = picked.path);
    }
  }

  void _addPage() {
    setState(() {
      _storyPages.add({"text": "", "image": ""});
    });
  }

  void _removePage(int index) {
    setState(() {
      _storyPages.removeAt(index);
    });
  }

  Future<void> _uploadStory() async {
    final title = _titleController.text.trim();

    if (title.isEmpty || _thumbnailFile == null || _storyPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Access repo manually (you could use a provider too)
      final cloudinaryRepo = CloudinaryRepository(
        CloudinaryService(),
        FirebaseDatabaseService(),
      );

      // 1️⃣ Upload thumbnail to Cloudinary
      final thumbnailUrl =
      await cloudinaryRepo.uploadSingleFile(_thumbnailFile!, isVideo: false);

      if (thumbnailUrl == null) throw Exception("Thumbnail upload failed");

      // 2️⃣ Upload story page images (if any)
      final uploadedPages = <Map<String, String>>[];
      for (final page in _storyPages) {
        final text = page["text"] ?? "";
        final imagePath = page["image"] ?? "";

        if (imagePath.isNotEmpty) {
          final imageUrl = await cloudinaryRepo.uploadSingleFile(
            File(imagePath),
            isVideo: false,
          );
          uploadedPages.add({"text": text, "image": imageUrl ?? ""});
        } else {
          uploadedPages.add({"text": text, "image": ""});
        }
      }

      // 3️⃣ Save story data to Firebase using the StoryViewModel
      await ref.read(storyViewModelProvider.notifier).saveStory(
        title: title,
        thumbnailUrl: thumbnailUrl,
        pages: uploadedPages,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story uploaded successfully!")),
      );

      context.goNamed('multiMediaContent');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(storyViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.goNamed('multiMediaContent'),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Add New Story"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Story Title", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: "Enter story title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 3.h),

            const Text("Thumbnail Image",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: _pickThumbnail,
              child: Container(
                height: 20.h,
                width: 100.w,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  image: _thumbnailFile != null
                      ? DecorationImage(
                    image: FileImage(_thumbnailFile!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _thumbnailFile == null
                    ? const Center(child: Text("Tap to upload thumbnail"))
                    : null,
              ),
            ),
            SizedBox(height: 3.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Story Pages",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _addPage,
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _storyPages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (val) => _storyPages[index]["text"] = val,
                          decoration: InputDecoration(
                            labelText: "Page ${index + 1} Text",
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
                          onTap: () => _pickPageImage(index),
                          child: Container(
                            height: 18.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                              image: _storyPages[index]["image"]!.isNotEmpty
                                  ? DecorationImage(
                                image: FileImage(
                                    File(_storyPages[index]["image"]!)),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _storyPages[index]["image"]!.isEmpty
                                ? const Center(
                              child: Text("Tap to upload page image"),
                            )
                                : null,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => _removePage(index),
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadStory,
                icon: const Icon(Icons.cloud_upload),
                label: _isUploading
                    ? const Text("Uploading...")
                    : const Text("Upload Story"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
