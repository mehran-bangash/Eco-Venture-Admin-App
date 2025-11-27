import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../models/video_model.dart';
import '../../../viewmodels/child_section/multimedia_content/admin_multimedia_provider.dart';


class AdminEditVideoScreen extends ConsumerStatefulWidget {
  final dynamic videoData; // Map or Model
  const AdminEditVideoScreen({super.key, required this.videoData});

  @override
  ConsumerState<AdminEditVideoScreen> createState() => _AdminEditVideoScreenState();
}

class _AdminEditVideoScreenState extends ConsumerState<AdminEditVideoScreen> {
  // --- PRO COLORS ---
  final Color _primary = const Color(0xFFE53935); // YouTube Red-ish
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _surface = Colors.white;
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);
  final Color _border = const Color(0xFFE0E0E0);

  // --- CONTROLLERS ---
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _durationController;

  // --- STATE ---
  late VideoModel _video;
  String _selectedCategory = 'Science';
  final List<String> _categories = ['Science', 'Maths', 'History', 'Ecosystem', 'Climate', 'Recycling'];

  File? _newVideoFile;
  File? _newThumbnail;
  String? _existingThumbnailUrl;
  String? _existingVideoUrl;

  @override
  void initState() {
    super.initState();

    // 1. Parse Data
    if (widget.videoData is VideoModel) {
      _video = widget.videoData;
    } else {
      final map = Map<String, dynamic>.from(widget.videoData);
      // FIX: Pass 'id' as first argument, and 'map' as second
      final String id = map['id']?.toString() ?? 'temp';
      _video = VideoModel.fromMap(id, map);
    }

    // 2. Pre-fill Controllers
    _titleController = TextEditingController(text: _video.title);
    _descController = TextEditingController(text: _video.description);
    _durationController = TextEditingController(text: _video.duration);

    _existingThumbnailUrl = _video.thumbnailUrl;
    _existingVideoUrl = _video.videoUrl;

    if (_categories.contains(_video.category)) {
      _selectedCategory = _video.category;
    } else {
      // Ensure category exists in list or add it temporarily if needed, or default to first
      if (!_categories.contains(_selectedCategory)) _selectedCategory = _categories.first;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newThumbnail = File(image.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _newVideoFile = File(video.path);
      });
    }
  }

  Future<void> _updateVideo() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Title is required"), backgroundColor: Colors.red)
      );
      return;
    }

    final updatedVideo = _video.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      category: _selectedCategory,
      videoUrl: _newVideoFile?.path ?? _existingVideoUrl,
      thumbnailUrl: _newThumbnail?.path ?? _existingThumbnailUrl,
      duration: _durationController.text.isNotEmpty ? _durationController.text : "00:00",
      // uploadedAt and stats are preserved via copyWith from original
    );

    // Call Admin ViewModel
    await ref.read(adminVideoViewModelProvider.notifier).updateVideo(updatedVideo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminVideoViewModelProvider);

    ref.listen(adminVideoViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Video Updated Successfully!"), backgroundColor: Colors.green)
        );
        ref.read(adminVideoViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red)
        );
      }
    });

    // Image Provider Logic
    ImageProvider? thumbnailProvider;
    if (_newThumbnail != null) {
      thumbnailProvider = FileImage(_newThumbnail!);
    } else if (_existingThumbnailUrl != null && _existingThumbnailUrl!.isNotEmpty) {
      thumbnailProvider = NetworkImage(_existingThumbnailUrl!);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Edit Video", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Video Details"),
                SizedBox(height: 2.h),

                _buildLabel("Video Title"),
                _buildTextField(_titleController, "Enter title"),
                SizedBox(height: 2.h),

                _buildLabel("Description"),
                _buildTextField(_descController, "Enter description", maxLines: 3),
                SizedBox(height: 2.h),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Category"),
                          _buildDropdown(),
                        ],
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Duration"),
                          _buildTextField(_durationController, "e.g. 05:30"),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                _buildSectionHeader("Media Content"),
                SizedBox(height: 2.h),

                // --- Thumbnail Upload ---
                _buildLabel("Thumbnail Image"),
                InkWell(
                  onTap: _pickThumbnail,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 20.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                      image: thumbnailProvider != null
                          ? DecorationImage(image: thumbnailProvider, fit: BoxFit.cover)
                          : null,
                    ),
                    child: thumbnailProvider == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported_rounded, size: 32.sp, color: Colors.grey.shade400),
                        SizedBox(height: 1.h),
                        Text("Tap to change thumbnail", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                      ],
                    )
                        : Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        margin: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                // --- Video Upload Box ---
                _buildLabel("Video File"),
                InkWell(
                  onTap: _pickVideo,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 18.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: (_newVideoFile != null)
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 40.sp, color: Colors.green),
                        SizedBox(height: 1.h),
                        Text("New Video Selected", style: GoogleFonts.poppins(fontSize: 15.sp, color: Colors.green, fontWeight: FontWeight.bold)),
                        SizedBox(height: 1.h),
                        Text("Tap to change", style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.blueGrey)),
                      ],
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_library, size: 40.sp, color: _primary),
                        SizedBox(height: 1.h),
                        Text("Current Video Active", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _textDark)),
                        Text("Tap to replace video", style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 5.h),

                // --- Update Button ---
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _updateVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: state.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Update Video", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
          if (state.isLoading)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 17.sp, fontWeight: FontWeight.w700, color: _textDark));

  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: _textDark)));

  Widget _buildTextField(TextEditingController ctrl, String hint, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(4.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primary, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: _primary),
          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
        ),
      ),
    );
  }
}