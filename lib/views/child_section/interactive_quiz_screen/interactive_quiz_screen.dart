import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../models/quiz_model.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_provider.dart';
import '../../../viewmodels/child_section/interactive_quiz/quiz_state.dart'; // Import provider

class InteractiveQuizScreen extends ConsumerStatefulWidget {
  const InteractiveQuizScreen({super.key});

  @override
  ConsumerState<InteractiveQuizScreen> createState() => _InteractiveQuizScreenState();
}

class _InteractiveQuizScreenState extends ConsumerState<InteractiveQuizScreen> {
  final Color _primary = const Color(0xFF05664F); // Eco Green
  final Color _bg = const Color(0xFFF5F7FA);

  String selectedCategory = 'Animals';
  final List<String> categories = [
    'Animals',
    'Ecosystem',
    'Maths',
    'Science',
     'Space',
    'Plants'
  ];

  // Store the scaffold messenger to show snackbars
  late ScaffoldMessengerState _messenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the Stream Provider based on the selected category
    final quizListAsync = ref.watch(quizListStreamProvider(selectedCategory));
    final quizViewModel = ref.watch(quizViewModelProvider.notifier);
    final quizState = ref.watch(quizViewModelProvider);

    // 2. Listen for success/error messages
    ref.listen<QuizState>(quizViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        _messenger.showSnackBar(
          SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red),
        );
      }
      if (next.isSuccess) {
        _messenger.showSnackBar(
          SnackBar(content: Text("Quiz saved successfully!"), backgroundColor: _primary),
        );
        quizViewModel.resetSuccess();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.goNamed("bottomNavChild");
        }
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 3.h),
                    _buildSectionTitle("Managed Levels", quizListAsync.valueOrNull?.length ?? 0),
                    SizedBox(height: 2.h),
                    Expanded(
                      child: quizListAsync.when(
                        data: (quizzes) {
                          if (quizzes.isEmpty) return _buildEmptyState();
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 10.h),
                            itemCount: quizzes.length,
                            itemBuilder: (context, index) => _buildProQuizCard(quizzes[index]),
                          );
                        },
                        loading: () => Center(child: CircularProgressIndicator(color: _primary)),
                        error: (err, stack) => Center(child: Text('Error loading quizzes: $err')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Show loading indicator over the Floating Action Button area
        floatingActionButton: quizState.isLoading
            ? Container(
          height: 7.h,
          width: 90.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: _primary.withOpacity(0.8)
          ),
          child: const CircularProgressIndicator(color: Colors.white),
        )
            : _buildAddButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(top: 6.h, left: 5.w, right: 5.w, bottom: 3.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primary, const Color(0xFF0A8F6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => context.goNamed("bottomNavChild"),
                child: Container(
                  height: 4.5.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                ),
              ),
              Text(
                'Quiz Dashboard',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 20,
                child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 18.sp),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primary),
                value: selectedCategory,
                items: categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.category_outlined, size: 14.sp, color: Colors.grey),
                        SizedBox(width: 2.w),
                        Text(
                          value,
                          style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!), // Trigger stream change
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        Text(
          '$count Levels',
          style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  // QUIZ CARD
  Widget _buildProQuizCard(QuizModel quiz) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            // Level Badge (Use Image if available)
            Container(
              height: 14.w,
              width: 14.w,
              decoration: BoxDecoration(
                color: quiz.imageUrl != null ? Colors.transparent : Colors.orange.shade500,
                borderRadius: BorderRadius.circular(16),
                image: quiz.imageUrl != null
                    ? DecorationImage(
                  image: NetworkImage(quiz.imageUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: quiz.imageUrl == null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LVL', style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                  Text('${quiz.order}', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                ],
              )
                  : null,
            ),
            SizedBox(width: 4.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3436)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.8.h),
                  _buildChip(Icons.list_alt, '${quiz.questions.length} Qs', Colors.blue.shade50, Colors.blue),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                // Edit
                InkWell(
                  onTap: () {
                    context.goNamed('editQuizScreen', extra: quiz); // Navigate to Edit
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.edit, size: 14.sp, color: _primary),
                  ),
                ),
                SizedBox(height: 1.5.h),
                // Delete
                InkWell(
                  onTap: () {
                    _showDeleteDialog(context, quiz); // Show Delete Dialog
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delete_outline, size: 14.sp, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 10.sp, color: text),
          SizedBox(width: 1.w),
          Text(label, style: GoogleFonts.poppins(fontSize: 8.sp, fontWeight: FontWeight.w500, color: text)),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 7.h,
      width: 90.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [_primary, const Color(0xFF0A8F6F)]),
        boxShadow: [BoxShadow(color: _primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.goNamed('addQuizScreen');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.white, size: 18.sp),
            SizedBox(width: 2.w),
            Text('Create New Level', style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, QuizModel quiz) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete Level?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to permanently remove '${quiz.title}'? This action cannot be undone.", style: GoogleFonts.poppins(fontSize: 10.sp)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Call delete from ViewModel
                if (quiz.id != null) {
                  ref.read(quizViewModelProvider.notifier).deleteQuiz(quiz.id!, quiz.category);
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 50.sp, color: Colors.grey[300]),
          Text('No Levels Yet', style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }
}