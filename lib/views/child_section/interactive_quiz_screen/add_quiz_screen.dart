import 'dart:io';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';


class AddQuizScreen extends ConsumerStatefulWidget {
  final String? initialCategory; // Optional: pass category if coming from dashboard
  const AddQuizScreen({super.key, this.initialCategory});

  @override
  ConsumerState<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends ConsumerState<AddQuizScreen> {
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF2F4F7);
  final Color _textDark = Colors.black;
  final Color _textLabel = const Color(0xFF333333);
  final Color _border = const Color(0xFFCFD8DC);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController(text: "60");

  String _selectedCategory = 'Animals';
  final List<String> _categories = ['Animals', 'Ecosystem', 'Recycling', 'Climate'];

  List<Map<String, dynamic>> _questions = [];
  File? _quizImage;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Create Quiz Level",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              separatorBuilder: (c, i) => SizedBox(height: 2.h),
              itemBuilder: (context, index) => _buildQuestionCard(index, _questions[index]),
            ),
            SizedBox(height: 5.h),
            _buildSaveButton(),
            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel("Target Category"),
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
                icon: Icon(Icons.arrow_drop_down_circle, color: _primary, size: 20.sp),
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
            ),
          ),
          SizedBox(height: 2.5.h),
          _buildLabel("Quiz Title"),
          _buildTextField(controller: _titleController, hint: "Jungle Sounds - Level 1", icon: Icons.title),
          SizedBox(height: 2.5.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Order #"),
                    _buildTextField(controller: _levelController, hint: "1", icon: Icons.sort, isNumber: true),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Pass %"),
                    _buildTextField(controller: _percentageController, hint: "60", icon: Icons.percent, isNumber: true),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          _buildLabel("Cover Image (Optional)"),
          InkWell(
            onTap: _pickQuizImage,
            child: Container(
              height: 12.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _quizImage == null ? Colors.grey.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _quizImage == null ? _border : _primary, width: 2),
                image: _quizImage != null
                    ? DecorationImage(image: FileImage(_quizImage!), fit: BoxFit.cover)
                    : null,
              ),
              child: _quizImage == null
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, color: Colors.grey[700], size: 18.sp),
                  SizedBox(width: 2.w),
                  Text("Tap to Upload", style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 11.sp, fontWeight: FontWeight.w600)),
                ],
              )
                  : Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => setState(() => _quizImage = null),
                  child: Container(
                    margin: EdgeInsets.all(2.w),
                    padding: EdgeInsets.all(1.w),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(Icons.close, size: 14.sp, color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickQuizImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => _quizImage = File(picked.path));
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, left: 0.5.w),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, size: 16.sp, color: Colors.grey[800]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _primary, width: 2.5),
        ),
      ),
    );
  }

  Widget _buildQuestionsHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Quiz Content", style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w800, color: _textDark)),
              Text("${_questions.length} Questions Ready", style: GoogleFonts.poppins(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
            ],
          ),
          ElevatedButton.icon(
            onPressed: _showAddQuestionSheet,
            icon: Icon(Icons.add, size: 14.sp, color: Colors.white),
            label: Text("ADD QUESTION", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _textDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.2.h),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestionsState() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_add, size: 32.sp, color: Colors.grey[400]),
            SizedBox(height: 1.h),
            Text("No questions yet", style: GoogleFonts.poppins(color: _textDark, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            Text("Tap '+ ADD QUESTION' to begin.", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 10.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, Map<String, dynamic> question) {
    bool hasImage = question['image_url'] != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(6)),
                  child: Text("Q${index + 1}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10.sp)),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => _questions.removeAt(index)),
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red[700], size: 14.sp),
                      SizedBox(width: 1.5.w),
                      Text("DELETE", style: GoogleFonts.poppins(color: Colors.red[700], fontSize: 10.sp, fontWeight: FontWeight.w800)),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question['question'], style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 13.sp, color: _textDark)),
                if (hasImage)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 1.5.h),
                    height: 18.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                      image: DecorationImage(image: FileImage(File(question['image_url'])), fit: BoxFit.cover),
                    ),
                  ),
                SizedBox(height: 1.5.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: (question['options'] as List<String>).map((opt) {
                    bool isCorrect = opt == question['answer'];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green.shade50 : Colors.white,
                        border: Border.all(color: isCorrect ? Colors.green : Colors.grey.shade400, width: isCorrect ? 2 : 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCorrect) Icon(Icons.check_circle, color: Colors.green[700], size: 12.sp),
                          if (isCorrect) SizedBox(width: 2.w),
                          Text(opt, style: GoogleFonts.poppins(fontSize: 11.sp, color: isCorrect ? Colors.green[800] : _textDark, fontWeight: isCorrect ? FontWeight.w800 : FontWeight.w600)),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddQuestionSheet() {
    String qText = "";
    File? questionImage;
    TextEditingController op1Ctrl = TextEditingController();
    TextEditingController op2Ctrl = TextEditingController();
    TextEditingController op3Ctrl = TextEditingController();
    TextEditingController op4Ctrl = TextEditingController();
    int selectedOptionIndex = -1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(builder: (context, setSheetState) {
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
                  Text("New Question", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _textDark)),
                  SizedBox(height: 3.h),
                  Text("QUESTION TEXT", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                  SizedBox(height: 1.h),
                  TextField(
                    onChanged: (v) => qText = v,
                    maxLines: 2,
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: "e.g. What animal is shown below?",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: EdgeInsets.all(4.w),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _border, width: 1.5)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primary, width: 2.5)),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text("IMAGE (OPTIONAL)", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                  SizedBox(height: 1.h),
                  InkWell(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked != null) setSheetState(() => questionImage = File(picked.path));
                    },
                    child: Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: questionImage == null ? Colors.grey.shade50 : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: questionImage == null ? _border : _primary, width: 2),
                        image: questionImage != null ? DecorationImage(image: FileImage(questionImage!), fit: BoxFit.cover) : null,
                      ),
                      child: questionImage == null
                          ? Center(child: Text("Tap to upload image", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11.sp, fontWeight: FontWeight.w600)))
                          : Align(
                        alignment: Alignment.topRight,
                        child: InkWell(onTap: () => setSheetState(() => questionImage = null), child: Icon(Icons.close, color: Colors.red, size: 18.sp)),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text("OPTIONS", style: GoogleFonts.poppins(fontSize: 9.sp, fontWeight: FontWeight.w900, color: _textLabel, letterSpacing: 0.8)),
                  SizedBox(height: 1.h),
                  ...List.generate(4, (i) {
                    TextEditingController ctrl = [op1Ctrl, op2Ctrl, op3Ctrl, op4Ctrl][i];
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrl,
                              style: GoogleFonts.poppins(fontSize: 12.sp, color: _textDark, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                hintText: "Option ${i + 1}",
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: EdgeInsets.all(3.w),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _border, width: 1.5)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: _primary, width: 2.5)),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          InkWell(
                            onTap: () => setSheetState(() => selectedOptionIndex = i),
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: selectedOptionIndex == i ? Colors.green : Colors.grey.shade400, width: 2),
                              ),
                              child: selectedOptionIndex == i ? Icon(Icons.check, size: 12.sp, color: Colors.green) : const SizedBox(width: 12, height: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 3.h),
                  ElevatedButton(
                    onPressed: () {
                      if (qText.isEmpty || selectedOptionIndex == -1 || [op1Ctrl, op2Ctrl, op3Ctrl, op4Ctrl].any((c) => c.text.isEmpty)) return;

                      setState(() {
                        _questions.add({
                          'question': qText,
                          'options': [op1Ctrl.text, op2Ctrl.text, op3Ctrl.text, op4Ctrl.text],
                          'answer': [op1Ctrl.text, op2Ctrl.text, op3Ctrl.text, op4Ctrl.text][selectedOptionIndex],
                          'image_url': questionImage?.path,
                        });
                      });

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text("ADD QUESTION", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: SizedBox(
        width: double.infinity,
        height: 7.h,
        child: ElevatedButton(
          onPressed: () async {
            if (_titleController.text.isEmpty || _levelController.text.isEmpty || _percentageController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all mandatory fields")));
              return;
            }

            // Convert questions to QuestionModel list
            List<QuestionModel> questionModels = _questions.map((q) {
              return QuestionModel(
                question: q['question'],
                options: List<String>.from(q['options']),
                answer: q['answer'],
                imageUrl: q['image_url'],
              );
            }).toList();

            // Admin ID
            String? adminId = await SharedPreferencesHelper.instance.getAdminId();
            adminId ??= await ref.read(quizViewModelProvider.notifier).getCurrentUserId();

            // Build QuizModel
            QuizModel newQuiz = QuizModel(
              category: _selectedCategory,
              title: _titleController.text,
              order: int.tryParse(_levelController.text) ?? 1,
              passingPercentage: int.tryParse(_percentageController.text) ?? 60,
              questions: questionModels,
              adminId: adminId,
              imageUrl: _quizImage?.path,
            );

            // Save via ViewModel
            await ref.read(quizViewModelProvider.notifier).addQuiz(newQuiz);

            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            "SAVE QUIZ LEVEL",
            style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
          ),
        ),
      ),
    );
  }
}
