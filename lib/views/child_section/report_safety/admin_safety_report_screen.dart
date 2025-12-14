import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

import '../../../viewmodels/child_section/report_safety/teacher_verification_provider.dart';

// ... (Keep your existing Mock ReportModel code here) ...
class ReportModel {
  final String id;
  final String issueType;
  final String source;
  final String reporterName;
  final String severity;
  final bool isResolved;
  ReportModel({
    required this.id,
    required this.issueType,
    required this.source,
    required this.reporterName,
    required this.severity,
    required this.isResolved,
  });
  static ReportModel mock(int index) => ReportModel(
    id: "$index",
    issueType: "Bullying",
    source: "Child",
    reporterName: "Student $index",
    severity: "High",
    isResolved: false,
  );
}

final safetyReportProvider =
    StateNotifierProvider<SafetyReportNotifier, List<ReportModel>>(
      (ref) => SafetyReportNotifier(),
    );

class SafetyReportNotifier extends StateNotifier<List<ReportModel>> {
  SafetyReportNotifier()
    : super(List.generate(5, (index) => ReportModel.mock(index)));
}

class AdminSafetyReportScreen extends ConsumerStatefulWidget {
  const AdminSafetyReportScreen({super.key});
  @override
  ConsumerState<AdminSafetyReportScreen> createState() =>
      _AdminSafetyReportScreenState();
}

class _AdminSafetyReportScreenState
    extends ConsumerState<AdminSafetyReportScreen> {
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _textGrey = const Color(0xFFA3AED0);

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(safetyReportProvider);
    final pendingReportsCount = reports.where((r) => !r.isResolved).length;

    // 1. Get Real Pending Count
    final teacherState = ref.watch(teacherVerificationViewModelProvider);
    final pendingTeacherCount = teacherState.pendingTeachers.length;

    // 2. Get Real Approved Count
    final approvedTeacherCount =
        ref.watch(approvedTeacherCountProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Safety Command Center",
          style: GoogleFonts.poppins(
            color: _textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Overview",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    title: "Pending Reports",
                    count: "$pendingReportsCount",
                    icon: Icons.report_problem_rounded,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  // 3. Updated Teacher Queue Card
                  child: _buildTeacherQueueCard(
                    pendingCount: pendingTeacherCount,
                    approvedCount: approvedTeacherCount,
                    onTap: () =>
                        context.pushNamed('adminTeacherVerificationScreen'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              "Recent Reports",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            // ... (Rest of your report list code remains same) ...
          ],
        ),
      ),
    );
  }

  // Standard Card
  Widget _buildActionCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 16.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18.sp),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: _textGrey,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: _textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom Teacher Queue Card
  Widget _buildTeacherQueueCard({
    required int pendingCount,
    required int approvedCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        height: 16.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: Colors.blue,
                    size: 18.sp,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: _textGrey,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "$pendingCount",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      "Pending",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  "$approvedCount Active Teachers",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: _textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
