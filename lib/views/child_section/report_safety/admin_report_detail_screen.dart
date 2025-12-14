import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/report_model.dart';
final safetyReportProvider = StateNotifierProvider<SafetyReportNotifier, List<ReportModel>>((ref) {
  return SafetyReportNotifier();
});

class SafetyReportNotifier extends StateNotifier<List<ReportModel>> {
  SafetyReportNotifier() : super([]);

  void resolveReport(String id) {
    // Mock logic: Print to console to simulate resolution
    debugPrint("Mock: Report $id resolved locally.");
  }
}

class AdminReportDetailScreen extends ConsumerWidget {
  final ReportModel report;

  const AdminReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: Text("Report Details", style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER INFO ---
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildDetailRow("Reporter", report.reporterName, Icons.person),
                  Divider(height: 3.h),
                  _buildDetailRow("Source", report.source, Icons.category),
                  Divider(height: 3.h),
                  _buildDetailRow("Type", report.issueType, Icons.warning_amber_rounded),
                  Divider(height: 3.h),
                  _buildDetailRow("Time", report.timestamp.toString().substring(0, 16), Icons.access_time),
                ],
              ),
            ),
            SizedBox(height: 3.h),

            Text("Message / Details", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Text(report.details, style: GoogleFonts.poppins(fontSize: 14.sp, height: 1.5, color: Colors.grey[800])),
            ),
            SizedBox(height: 5.h),

            // --- ACTIONS ---
            if (!report.isResolved) ...[
              // SUSPEND USER BUTTON
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton.icon(
                  onPressed: () => _showSuspendDialog(context, report.reporterName),
                  icon: const Icon(Icons.block),
                  label: Text("Suspend User", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // RESOLVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 6.5.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Update State using local mock provider
                    ref.read(safetyReportProvider.notifier).resolveReport(report.id);
                    // Show Success
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report Resolved & Users Notified"), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text("Mark as Resolved", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 2.w),
                      Text("This issue is resolved", style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 18.sp, color: Colors.grey.shade700),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        )
      ],
    );
  }

  void _showSuspendDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Suspension"),
        content: Text("Are you sure you want to suspend $userName? They will lose access immediately."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              // TODO: Call API to suspend
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User Suspended"), backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Suspend", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}