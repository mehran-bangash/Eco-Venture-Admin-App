import 'dart:convert';
import 'dart:io';
import 'package:eco_venture_admin_portal/core/config/api_constant.dart';
import 'package:http/http.dart' as http; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/quiz_topic_model.dart';
import '../../../services/shared_preferences_helper.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';

class AddQuizScreen extends ConsumerStatefulWidget {
  const AddQuizScreen({super.key});

  @override
  ConsumerState<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends ConsumerState<AddQuizScreen> {
  // --- COLORS ---
  final Color _primary = const Color(0xFF05664F);
  final Color _bg = const Color(0xFFF2F4F7);
  final Color _textDark = Colors.black;
  final Color _textLabel = const Color(0xFF333333);
  final Color _border = const Color(0xFFCFD8DC);

  // --- TOPIC STATE ---
  final TextEditingController _topicNameController = TextEditingController();

  // --- NEW FIELDS ---
  final TextEditingController _tagsController = TextEditingController();
  bool _isSensitive = false;
  // -----------------

  String _selectedCategory = 'Animals';
  final List<String> _categories = [
    'Animals',
    'Ecosystem',
    'Science',
    'Space',
    'Plants',
    'Mathematics',
  ];

  // List to hold levels before saving
  List<QuizLevelModel> _levels = [];

  @override
  void dispose() {
    _topicNameController.dispose();
    _tagsController.dispose(); // Dispose new controller
    super.dispose();
  }

  // --- SAVE LOGIC ---
  Future<void> _saveTopic() async {
    if (_topicNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a Topic Name")),
      );
      return;
    }

    if (_levels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one Level")),
      );
      return;
    }

    String? adminId = await SharedPreferencesHelper.instance.getAdminId();
    adminId ??= FirebaseAuth.instance.currentUser?.uid;

    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin ID missing. Re-login.")),
      );
      return;
    }

    // --- 1. Process Tags & Sensitivity ---
    List<String> tagsList = _tagsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (_isSensitive && !tagsList.contains('scary')) {
      tagsList.add('scary');
    }
    if (!_isSensitive) {
      tagsList.remove('scary');
    }

    final newTopic = QuizTopicModel(
      category: _selectedCategory,
      topicName: _topicNameController.text.trim(),
      createdBy: 'admin',
      creatorId: adminId,
      levels: _levels,
      // Pass new fields to model
      tags: tagsList,
      isSensitive: _isSensitive,
    );

    try {
      // 2. Save to Firebase
      await ref.read(quizViewModelProvider.notifier).addTopic(newTopic);

      // 3. Trigger Notification via Node.js Backend
      // Only notify if it's NOT sensitive (or based on your preference)
      if (!_isSensitive) {
        _sendNotificationToUsers(newTopic.topicName, newTopic.category);
      }
    } catch (e) {
      print("ViewModel error: $e");
    }
  }

  // --- CALL NODE JS BACKEND ---
  Future<void> _sendNotificationToUsers(String topicName, String category) async {
    const String backendUrl = ApiConstants.notifyByRoleEndPoints;

    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": "New Quiz Added! 🧠",
          "body": "Can you beat the new '$topicName' quiz?",
          "type": "Quiz",
          "targetRole": "child" // <--- CRITICAL: ONLY NOTIFY CHILDREN
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Child Notification sent successfully");
      } else {
        print("❌ Notification failed: ${response.body}");
      }
    } catch (e) {
      print("❌ Error calling backend: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizViewModelProvider);

    ref.listen(quizViewModelProvider, (previous, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Topic '${_topicNameController.text}' Saved & Users Notified!",
            ),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(quizViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${next.errorMessage}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

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
          "Create New Topic",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Topic Information"),
                SizedBox(height: 2.h),

                _buildLabel("Category"),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _primary,
                        size: 22.sp,
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(
                                c,
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                    ),
                  ),
                ),
                SizedBox(height: 2.5.h),

                _buildLabel("Topic Name"),
                _buildTextField(
                  controller: _topicNameController,
                  hint: "e.g. Solar System",
                  icon: Icons.topic,
                ),

                // --- NEW UI ELEMENTS ---
                SizedBox(height: 2.5.h),
                _buildLabel("Tags (comma-separated)"),
                _buildTextField(
                  controller: _tagsController,
                  hint: "e.g. history, fun, basics",
                  icon: Icons.tag,
                ),

                SizedBox(height: 2.5.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: SwitchListTile(
                    activeThumbColor: Colors.red,
                    title: Text(
                      "Sensitive Content",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    subtitle: Text(
                      "Hide from younger children",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                    value: _isSensitive,
                    onChanged: (val) => setState(() => _isSensitive = val),
                  ),
                ),

                // -----------------------
                SizedBox(height: 4.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader("Levels (${_levels.length})"),
                    ElevatedButton.icon(
                      onPressed: () => _showLevelEditor(),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        "Add Level",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _textDark,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                if (_levels.isEmpty)
                  Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _border),
                    ),
                    child: Center(
                      child: Text(
                        "No levels added yet.\nClick 'Add Level' to start.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _levels.length,
                    separatorBuilder: (c, i) => SizedBox(height: 2.h),
                    itemBuilder: (context, index) =>
                        _buildLevelCard(index, _levels[index]),
                  ),

                SizedBox(height: 5.h),

                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: quizState.isLoading ? null : _saveTopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: quizState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "SAVE TOPIC",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 3.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... [KEEP ALL THE EXISTING HELPER WIDGETS AND LEVEL EDITOR LOGIC] ...
  // ... [KEEP _buildSectionHeader, _buildLabel, _buildTextField, etc.] ...
  // ... [KEEP _showLevelEditor, _showQuestionEditor] ...
  // (I am not repeating them to save space, but they must be kept exactly as they were)

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: _primary,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, left: 1.w),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: _textLabel,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(
        fontSize: 14.sp,
        color: _textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade400,
          fontSize: 14.sp,
        ),
        prefixIcon: Icon(icon, size: 18.sp, color: _textDark),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 2.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primary, width: 2.5),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int index, QuizLevelModel level) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Level ${level.order}: ${level.title}",
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue, size: 18.sp),
                    onPressed: () =>
                        _showLevelEditor(existingLevel: level, index: index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 18.sp),
                    onPressed: () => setState(() => _levels.removeAt(index)),
                  ),
                ],
              ),
            ],
          ),
          Divider(color: Colors.grey.shade200),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoBadge(Icons.star, "${level.points} Pts", Colors.amber),
              _buildInfoBadge(
                Icons.percent,
                "${level.passingPercentage}% Pass",
                Colors.blue,
              ),
              _buildInfoBadge(
                Icons.help_outline,
                "${level.questions.length} Qs",
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: color),
        SizedBox(width: 1.5.w),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _showLevelEditor({QuizLevelModel? existingLevel, int? index}) {
    final titleCtrl = TextEditingController(text: existingLevel?.title ?? "");
    final orderCtrl = TextEditingController(
      text: existingLevel?.order.toString() ?? "${_levels.length + 1}",
    );
    final pointsCtrl = TextEditingController(
      text: existingLevel?.points.toString() ?? "10",
    );
    final passCtrl = TextEditingController(
      text: existingLevel?.passingPercentage.toString() ?? "60",
    );

    List<QuestionModel> tempQuestions = existingLevel != null
        ? List.from(existingLevel.questions)
        : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: 90.h,
            padding: EdgeInsets.fromLTRB(
              5.w,
              2.h,
              5.w,
              MediaQuery.of(context).viewInsets.bottom + 2.h,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 15.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  existingLevel == null ? "Add Level" : "Edit Level",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                            labelText: "Level Title",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: orderCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Order",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: TextField(
                                controller: pointsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Points",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: TextField(
                                controller: passCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: "Pass %",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Questions (${tempQuestions.length})",
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showQuestionEditor(context, (newQ) {
                                  setModalState(() => tempQuestions.add(newQ));
                                });
                              },
                              icon: const Icon(Icons.add_circle),
                              label: Text(
                                "Add Question",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (tempQuestions.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(2.h),
                              child: Text(
                                "Add at least one question",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: tempQuestions.length,
                            itemBuilder: (c, i) {
                              final q = tempQuestions[i];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  "Q${i + 1}: ${q.question}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => setModalState(
                                    () => tempQuestions.removeAt(i),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.5.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isEmpty || tempQuestions.isEmpty)
                        return;

                      final newLevel = QuizLevelModel(
                        title: titleCtrl.text,
                        order: int.tryParse(orderCtrl.text) ?? 1,
                        passingPercentage: int.tryParse(passCtrl.text) ?? 60,
                        points: int.tryParse(pointsCtrl.text) ?? 10,
                        questions: tempQuestions,
                      );

                      setState(() {
                        if (index != null) {
                          _levels[index] = newLevel;
                        } else {
                          _levels.add(newLevel);
                        }
                        _levels.sort((a, b) => a.order.compareTo(b.order));
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _textDark),
                    child: Text(
                      index == null ? "ADD LEVEL" : "UPDATE LEVEL",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showQuestionEditor(BuildContext ctx, Function(QuestionModel) onSave) {
    String qText = "";
    File? qImage;
    final op1Ctrl = TextEditingController();
    final op2Ctrl = TextEditingController();
    final op3Ctrl = TextEditingController();
    final op4Ctrl = TextEditingController();
    int selectedOptionIndex = -1;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: 85.h,
          padding: EdgeInsets.fromLTRB(
            5.w,
            2.h,
            5.w,
            MediaQuery.of(context).viewInsets.bottom + 2.h,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "New Question",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),

                TextField(
                  onChanged: (v) => qText = v,
                  decoration: const InputDecoration(hintText: "Question Text"),
                ),
                SizedBox(height: 2.h),

                InkWell(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? img = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (img != null) setState(() => qImage = File(img.path));
                  },
                  child: Container(
                    height: 10.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(color: _primary),
                      borderRadius: BorderRadius.circular(8),
                      image: qImage != null
                          ? DecorationImage(
                              image: FileImage(qImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: qImage == null
                        ? Center(
                            child: Text(
                              "Tap to add Image (Optional)",
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: _primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 2.h),

                ...List.generate(4, (i) {
                  final ctrl = [op1Ctrl, op2Ctrl, op3Ctrl, op4Ctrl][i];
                  return RadioListTile(
                    title: TextField(
                      controller: ctrl,
                      decoration: InputDecoration(hintText: "Option ${i + 1}"),
                    ),
                    value: i,
                    groupValue: selectedOptionIndex,
                    onChanged: (v) => setState(() => selectedOptionIndex = v!),
                  );
                }),

                SizedBox(height: 3.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (qText.isEmpty || selectedOptionIndex == -1) return;
                      onSave(
                        QuestionModel(
                          question: qText,
                          options: [
                            op1Ctrl.text,
                            op2Ctrl.text,
                            op3Ctrl.text,
                            op4Ctrl.text,
                          ],
                          answer: [
                            op1Ctrl.text,
                            op2Ctrl.text,
                            op3Ctrl.text,
                            op4Ctrl.text,
                          ][selectedOptionIndex],
                          imageUrl: qImage?.path,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: _primary),
                    child: Text(
                      "SAVE QUESTION",
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
