import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';

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
  final List<String> _categories = ['Animals', 'Ecosystem', 'Space', 'Science','Plants','Maths'];

  // Local state for questions list
  late List<Map<String, dynamic>> _questions;

  File? _coverImageFile;
  String? _coverImageUrl;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.quizData.title);
    _levelController = TextEditingController(text: widget.quizData.order.toString());
    _percentageController = TextEditingController(text: widget.quizData.passingPercentage.toString());
    _selectedCategory = widget.quizData.category;

    // Deep copy of questions to allow editing without modifying original until save
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
        _coverImageUrl = null;
      });
    }
  }

  ImageProvider? _getCoverImage() {
    if (_coverImageFile != null) return FileImage(_coverImageFile!);
    if (_coverImageUrl != null && _coverImageUrl!.isNotEmpty) return NetworkImage(_coverImageUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
          if (quizState.isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
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
          style: ElevatedButton.styleFrom(backgroundColor: _textDark, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    bool hasImage = question['image_url'] != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        leading: hasImage
            ? ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(question['image_url'], width: 12.w, height: 12.w, fit: BoxFit.cover,
            errorBuilder: (c,e,s) => Icon(Icons.image_not_supported),
          ),
        )
            : CircleAvatar(child: Text("${index+1}")),
        title: Text(question['question'] ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text("Ans: ${question['answer']}", style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.green)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showQuestionSheet(index: index, existingQuestion: question),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => setState(() => _questions.removeAt(index)),
            ),
          ],
        ),
      ),
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
          onPressed: isLoading ? null : _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text("SAVE CHANGES", style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    List<QuestionModel> questionModels = _questions.map((q) {
      return QuestionModel(
        question: q['question'],
        options: List<String>.from(q['options']),
        answer: q['answer'],
        imageUrl: q['image_url'],
      );
    }).toList();

    final String? finalImageUrlString = _coverImageFile?.path ?? _coverImageUrl;

    QuizModel updatedQuiz = widget.quizData.copyWith(
      category: _selectedCategory,
      title: _titleController.text,
      order: int.tryParse(_levelController.text) ?? 1,
      passingPercentage: int.tryParse(_percentageController.text) ?? 60,
      questions: questionModels,
      imageUrl: finalImageUrlString,
    );

    await ref.read(quizViewModelProvider.notifier).updateQuiz(updatedQuiz);

    if (!mounted) return;
    Navigator.pop(context);
  }

  // --- COMPLETE QUESTION SHEET LOGIC ---
  void _showQuestionSheet({int? index, Map<String, dynamic>? existingQuestion}) {
    // 1. Setup initial values
    String qText = existingQuestion?['question'] ?? "";
    List<dynamic> currentOpts = existingQuestion?['options'] ?? ["", "", "", ""];
    String currentAnswer = existingQuestion?['answer'] ?? "";
    String? qImageUrl = existingQuestion?['image_url'];

    // 2. Controllers
    TextEditingController op1Ctrl = TextEditingController(text: currentOpts.length > 0 ? currentOpts[0] : "");
    TextEditingController op2Ctrl = TextEditingController(text: currentOpts.length > 1 ? currentOpts[1] : "");
    TextEditingController op3Ctrl = TextEditingController(text: currentOpts.length > 2 ? currentOpts[2] : "");
    TextEditingController op4Ctrl = TextEditingController(text: currentOpts.length > 3 ? currentOpts[3] : "");

    // 3. Determine correct index (if editing)
    int selectedOptionIndex = -1;
    if (currentAnswer.isNotEmpty) {
      // Check which option matches the answer string
      if (op1Ctrl.text == currentAnswer) selectedOptionIndex = 0;
      else if (op2Ctrl.text == currentAnswer) selectedOptionIndex = 1;
      else if (op3Ctrl.text == currentAnswer) selectedOptionIndex = 2;
      else if (op4Ctrl.text == currentAnswer) selectedOptionIndex = 3;
    }

    // 4. Local Image File (for picking new one)
    File? newImageFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (_, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                    ),
                    padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, MediaQuery.of(context).viewInsets.bottom + 2.h),
                    child: ListView(
                      controller: controller,
                      children: [
                        Center(child: Container(width: 15.w, height: 0.6.h, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                        SizedBox(height: 3.h),

                        Text(index == null ? "Add Question" : "Edit Question", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _textDark)),
                        SizedBox(height: 3.h),

                        // Question Input
                        Text("QUESTION TEXT", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                        SizedBox(height: 1.h),
                        TextField(
                          onChanged: (v) => qText = v,
                          controller: TextEditingController(text: qText)..selection = TextSelection.fromPosition(TextPosition(offset: qText.length)),
                          maxLines: 2,
                          style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: "Enter question...",
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Image Picker
                        Text("IMAGE (OPTIONAL)", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                        SizedBox(height: 1.h),
                        InkWell(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                            if (picked != null) {
                              setSheetState(() {
                                newImageFile = File(picked.path);
                              });
                            }
                          },
                          child: Container(
                            height: 12.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _border, width: 1.5),
                              image: newImageFile != null
                                  ? DecorationImage(image: FileImage(newImageFile!), fit: BoxFit.cover)
                                  : (qImageUrl != null && newImageFile == null
                                  ? DecorationImage(image: NetworkImage(qImageUrl!), fit: BoxFit.cover)
                                  : null),
                            ),
                            child: (newImageFile == null && qImageUrl == null)
                                ? Center(child: Text("Tap to attach image", style: GoogleFonts.poppins(color: Colors.grey[600], fontWeight: FontWeight.w600)))
                                : Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () => setSheetState(() {
                                  newImageFile = null;
                                  qImageUrl = null;
                                }),
                                child: Container(
                                  margin: EdgeInsets.all(2.w),
                                  padding: EdgeInsets.all(1.w),
                                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  child: Icon(Icons.close, color: Colors.red, size: 16.sp),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),

                        // Options
                        Text("OPTIONS (SELECT CORRECT ANSWER)", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                        SizedBox(height: 1.h),

                        _buildOptionInput(0, "Option A", op1Ctrl, selectedOptionIndex, (idx) => setSheetState(() => selectedOptionIndex = idx)),
                        _buildOptionInput(1, "Option B", op2Ctrl, selectedOptionIndex, (idx) => setSheetState(() => selectedOptionIndex = idx)),
                        _buildOptionInput(2, "Option C", op3Ctrl, selectedOptionIndex, (idx) => setSheetState(() => selectedOptionIndex = idx)),
                        _buildOptionInput(3, "Option D", op4Ctrl, selectedOptionIndex, (idx) => setSheetState(() => selectedOptionIndex = idx)),

                        SizedBox(height: 4.h),

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 7.h,
                          child: ElevatedButton(
                            onPressed: () {
                              // Validation
                              if (qText.isNotEmpty && selectedOptionIndex != -1) {
                                // Grab values
                                List<String> options = [op1Ctrl.text, op2Ctrl.text, op3Ctrl.text, op4Ctrl.text];
                                String correctAns = options[selectedOptionIndex];
                                String? finalImg = newImageFile?.path ?? qImageUrl;

                                // Create Map
                                Map<String, dynamic> questionData = {
                                  'question': qText,
                                  'options': options,
                                  'answer': correctAns,
                                  'image_url': finalImg,
                                };

                                setState(() {
                                  if (index != null) {
                                    // UPDATE existing
                                    _questions[index] = questionData;
                                  } else {
                                    // ADD new
                                    _questions.add(questionData);
                                  }
                                });
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter text and select an answer")));
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: Text(index == null ? "ADD QUESTION" : "UPDATE QUESTION", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w900)),
                          ),
                        )
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  Widget _buildOptionInput(int index, String label, TextEditingController controller, int selectedIndex, Function(int) onSelect) {
    bool isSelected = selectedIndex == index;
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? _primary : _border, width: isSelected ? 2.5 : 1.5),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? _primary.withOpacity(0.08) : Colors.white,
      ),
      child: Row(
        children: [
          Radio<int>(
            value: index,
            groupValue: selectedIndex,
            activeColor: _primary,
            onChanged: (val) => onSelect(val!),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w600),
              decoration: InputDecoration(hintText: label, border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}