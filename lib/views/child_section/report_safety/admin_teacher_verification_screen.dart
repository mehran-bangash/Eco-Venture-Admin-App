import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/child_section/report_safety/teacher_verification_provider.dart';

class AdminTeacherVerificationScreen extends ConsumerWidget {
  const AdminTeacherVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the STATE
    final state = ref.watch(teacherVerificationViewModelProvider);

    // 2. Read the VIEWMODEL (Notifier) for actions
    final viewModel = ref.read(teacherVerificationViewModelProvider.notifier);

    // Listen for errors to show SnackBars
    ref.listen(teacherVerificationViewModelProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text(
          "Teacher Verification",
          style: GoogleFonts.poppins(color: const Color(0xFF1B2559), fontWeight: FontWeight.w700, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2559)),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // MAIN LIST
          if (state.pendingTeachers.isEmpty && !state.isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 40.sp, color: Colors.green),
                  SizedBox(height: 2.h),
                  Text("All caught up!", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey)),
                  Text("No pending teacher requests.", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey)),
                ],
              ),
            )
          else
            ListView.builder(
              padding: EdgeInsets.all(5.w),
              itemCount: state.pendingTeachers.length,
              itemBuilder: (context, index) {
                final teacher = state.pendingTeachers[index];
                return Card(
                  elevation: 0,
                  margin: EdgeInsets.only(bottom: 2.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade50,
                              radius: 25,
                              child: Text(
                                teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
                                style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(teacher.name, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                                  Text(teacher.email, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey)),
                                  SizedBox(height: 0.5.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text("Pending Approval", style: TextStyle(fontSize: 10.sp, color: Colors.orange, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: state.isLoading ? null : () {
                                  viewModel.rejectTeacher(teacher.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Reject"),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: state.isLoading ? null : () {
                                  viewModel.approveTeacher(teacher.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00C853),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text("Approve Access"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // LOADING OVERLAY
          if (state.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}