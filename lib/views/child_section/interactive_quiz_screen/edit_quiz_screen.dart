import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // REQUIRED
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart'; // REQUIRED

// 1. Convert to ConsumerStatefulWidget
class EditQuizScreen extends ConsumerStatefulWidget {
  final QuizModel quizData;

  const EditQuizScreen({super.key, required this.quizData});

  @override
  ConsumerState<EditQuizScreen> createState() => _EditQuizScreenState();
}

class _EditQuizScreenState extends ConsumerState<EditQuizScreen> {
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF2F4F7);
  final Color _textDark = Colors.black;
  final Color _textLabel = const Color(0xFF333333);
  final Color _border = const Color(0xFFCFD8DC);

  late TextEditingController _titleController;
  late TextEditingController _levelController;
  late TextEditingController _percentageController;

  late String _selectedCategory;
  final List<String> _categories = ['Animals', 'Ecosystem', 'Recycling', 'Climate'];
  late List<Map<String, dynamic>> _questions;

  File? _coverImageFile; // Used for newly picked image (path)
  String? _coverImageUrl; // Used for existing network URL

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.quizData.title);
    _levelController = TextEditingController(text: widget.quizData.order.toString());
    _percentageController = TextEditingController(text: widget.quizData.passingPercentage.toString());
    _selectedCategory = widget.quizData.category;
    // Map QuestionModel list to List<Map> for easy state management in the UI
    _questions = widget.quizData.questions.map((q) => q.toMap()).toList();
    _coverImageUrl = widget.quizData.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _levelController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _coverImageFile = File(pickedFile.path);
        _coverImageUrl = null; // Clear existing URL if a new file is picked
      });
    }
  }

  // Helper to determine the image source for the UI display
  ImageProvider? _getCoverImage() {
    if (_coverImageFile != null) return FileImage(_coverImageFile!);
    if (_coverImageUrl != null) return NetworkImage(_coverImageUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Watch ViewModel for loading and error states
    final quizState = ref.watch(quizViewModelProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Quiz Level",
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15.sp,
              letterSpacing: 0.5),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Header (Removed transform offset as it was complicating things)
                Container(
                  width: double.infinity,
                  color: _primary,
                  padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Update Content", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w800)),
                      SizedBox(height: 0.5.h),
                      Text("Modifying: ${widget.quizData.title}", style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 10.sp)),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      _buildFormCard(),
                      SizedBox(height: 4.h),
                      _buildQuestionsHeader(),
                      SizedBox(height: 2.h),
                      _questions.isEmpty
                          ? _buildEmptyQuestionsState()
                          : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        separatorBuilder: (_, __) => SizedBox(height: 2.h),
                        itemBuilder: (_, i) => _buildQuestionCard(i, _questions[i]),
                      ),
                      SizedBox(height: 5.h),
                      _buildSaveButton(quizState.isLoading),
                      SizedBox(height: 5.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Loading Indicator Overlay
          if (quizState.isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 2.h),
                    Text("Saving changes...", style: GoogleFonts.poppins(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Category"),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              border: Border.all(color: _border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          _buildLabel("Quiz Title"),
          _buildTextField(controller: _titleController, hint: "Quiz Title", icon: Icons.title),
          SizedBox(height: 2.5.h),
          Row(
            children: [
              Expanded(child: _buildLabelledTextField("Order #", _levelController, Icons.sort, true)),
              SizedBox(width: 4.w),
              Expanded(child: _buildLabelledTextField("Pass %", _percentageController, Icons.percent, true)),
            ],
          ),
          SizedBox(height: 2.5.h),
          _buildLabel("Cover Image"),
          InkWell(
            onTap: _pickCoverImage,
            child: Container(
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primary, width: 2),
                image: _getCoverImage() != null
                    ? DecorationImage(image: _getCoverImage()!, fit: BoxFit.cover)
                    : null,
              ),
              child: _getCoverImage() == null
                  ? Center(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit), SizedBox(width: 2.w), Text("Pick Image")]))
                  : Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => setState(() {
                    _coverImageFile = null;
                    _coverImageUrl = null;
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: EdgeInsets.only(bottom: 1.h),
    child: Text(text.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel)),
  );

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildLabelledTextField(String label, TextEditingController controller, IconData icon, bool isNumber) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label),
      _buildTextField(controller: controller, hint: label, icon: icon),
    ]);
  }

  Widget _buildQuestionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Questions (${_questions.length})", style: GoogleFonts.poppins(fontWeight: FontWeight.w800)),
        ElevatedButton.icon(
          onPressed: () => _showQuestionSheet(),
          icon: const Icon(Icons.add, size: 16),
          label: const Text("ADD NEW"),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    return ListTile(
      title: Text(question['question'] ?? ""),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => setState(() => _questions.removeAt(index)),
      ),
      onTap: () => _showQuestionSheet(index: index, existingQuestion: question),
    );
  }

  Widget _buildEmptyQuestionsState() => Center(child: Text("No questions added"));

  Widget _buildSaveButton(bool isLoading) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        width: double.infinity,
        height: 7.h,
        child: ElevatedButton(
          onPressed: isLoading ? null : _saveChanges, // Disable if loading
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            "SAVE CHANGES",
            style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }

  // --- SAVE LOGIC ---
  Future<void> _saveChanges() async {
    // 1. Convert questions to QuestionModel list
    List<QuestionModel> questionModels = _questions.map((q) {
      // NOTE: q['image_url'] will be either a local path (if picked now) or a network URL (if loaded from DB)
      return QuestionModel(
        question: q['question'],
        options: List<String>.from(q['options']),
        answer: q['answer'],
        imageUrl: q['image_url'],
      );
    }).toList();

    // 2. Determine the final image URL string to pass to ViewModel
    // The ViewModel handles uploading the file path if it's a local file.
    final String? finalImageUrlString = _coverImageFile?.path ?? _coverImageUrl;

    // 3. Construct the updated QuizModel (must keep the original ID)
    QuizModel updatedQuiz = widget.quizData.copyWith(
      category: _selectedCategory,
      title: _titleController.text,
      order: int.tryParse(_levelController.text) ?? 1,
      passingPercentage: int.tryParse(_percentageController.text) ?? 60,
      questions: questionModels,
      imageUrl: finalImageUrlString,
    );

    // 4. Call update via ViewModel
    await ref.read(quizViewModelProvider.notifier).updateQuiz(updatedQuiz);

    if (!mounted) return;
    Navigator.pop(context); // Navigate back after save
  }

  void _showQuestionSheet({int? index, Map<String, dynamic>? existingQuestion}) {
    // Placeholder: You will implement your modal bottom sheet logic here
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Question Sheet opened for editing!")));
  }
}