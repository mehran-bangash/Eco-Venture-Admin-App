import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../models/qr_hunt_model.dart';
import '../../../viewmodels/child_section/qr_treasure_hunt/admin_treasure_hunt_provider.dart';


class AdminAddTreasureHuntScreen extends ConsumerStatefulWidget {
  const AdminAddTreasureHuntScreen({super.key});

  @override
  ConsumerState<AdminAddTreasureHuntScreen> createState() => _AdminAddTreasureHuntScreenState();
}

class _AdminAddTreasureHuntScreenState extends ConsumerState<AdminAddTreasureHuntScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  String _difficulty = 'Easy';
  final List<String> _difficultyLevels = ['Easy', 'Medium', 'Hard'];

  final List<TextEditingController> _clueControllers = [TextEditingController(), TextEditingController()];

  // Generate a unique ID for this hunt session immediately
  final String _tempHuntId = DateTime.now().millisecondsSinceEpoch.toString();

  final Color _primary = const Color(0xFF00C853);
  final Color _bg = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1B2559);
  final Color _border = const Color(0xFFE0E0E0);

  // --- SAVE LOGIC ---
  Future<void> _saveHunt() async {
    if (_titleController.text.isEmpty || _pointsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields"), backgroundColor: Colors.red));
      return;
    }

    List<String> clues = _clueControllers.where((c) => c.text.isNotEmpty).map((c) => c.text).toList();
    if (clues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one clue"), backgroundColor: Colors.red));
      return;
    }

    final newHunt = QrHuntModel(
      // Use the ID we generated for the QRs
      id: _tempHuntId,
      title: _titleController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 100,
      difficulty: _difficulty,
      clues: clues,
      createdAt: DateTime.now(),
      adminId: '', // Service fills this
    );

    await ref.read(adminTreasureHuntViewModelProvider.notifier).addHunt(newHunt);
  }

  // --- 2. GENERATE & PRINT PDF (MULTI QRs) ---
  // This logic is identical to the Teacher Portal's implementation
  Future<void> _generateAndPrintPdf() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a Title first!"), backgroundColor: Colors.orange));
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();

          // Loop through clues to create a unique QR for each
          for (int i = 0; i < _clueControllers.length; i++) {
            // Logic: "HUNT_ID_CLUE_INDEX"
            // Example: "17382912_0", "17382912_1"
            final qrData = "${_tempHuntId}_$i";

            doc.addPage(
              pw.Page(
                pageFormat: format,
                build: (pw.Context context) {
                  return pw.Center(
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text("Clue #${i + 1}", style: pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 10),
                        pw.Text("Hunt: ${_titleController.text}", style: pw.TextStyle(fontSize: 20, color: PdfColors.grey700)),
                        pw.SizedBox(height: 40),

                        // Generate QR
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: qrData,
                          width: 300,
                          height: 300,
                        ),

                        pw.SizedBox(height: 40),
                        pw.Text("Hide this QR code at location #${i + 1}", style: pw.TextStyle(fontSize: 18)),
                        pw.SizedBox(height: 10),
                        pw.Text("Players must find this to unlock Clue #${i + 2} (or finish).", style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                      ],
                    ),
                  );
                },
              ),
            );
          }
          return doc.save();
        },
      );
    } catch (e) {
      print("Print Error: $e");
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error generating PDF: $e"), backgroundColor: Colors.red));
    }
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminTreasureHuntViewModelProvider);

    ref.listen(adminTreasureHuntViewModelProvider, (prev, next) {
      if (next.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("QR Hunt Created!"), backgroundColor: Colors.green));
        ref.read(adminTreasureHuntViewModelProvider.notifier).resetSuccess();
        Navigator.pop(context);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${next.errorMessage}"), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp), onPressed: () => Navigator.pop(context)),
        title: Text("Admin: Add QR Hunt", style: GoogleFonts.poppins(color: _textDark, fontWeight: FontWeight.bold, fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Create a new global task for all students.", style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey[600])),
                SizedBox(height: 3.h),

                _buildLabel("Task Name / Title"),
                _buildTextField(_titleController, "Enter task title"),

                SizedBox(height: 2.h),
                _buildLabel("Points"),
                _buildTextField(_pointsController, "100", isNumber: true),

                SizedBox(height: 2.h),
                _buildLabel("Difficulty"),
                _buildDropdown(),

                SizedBox(height: 4.h),
                _buildSectionHeader("Clues"),

                ...List.generate(_clueControllers.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Clue ${index + 1}", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                            if (index > 0) InkWell(onTap: () => setState(() => _clueControllers.removeAt(index)), child: Text("Remove", style: TextStyle(color: Colors.red, fontSize: 13.sp)))
                          ],
                        ),
                        SizedBox(height: 1.h),
                        _buildTextField(_clueControllers[index], "Enter hint", maxLines: 2),
                      ],
                    ),
                  );
                }),

                InkWell(
                  onTap: () => setState(() => _clueControllers.add(TextEditingController())),
                  child: Row(children: [Icon(Icons.add, color: _textDark, size: 18.sp), SizedBox(width: 2.w), Text("Add Clue", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _textDark))]),
                ),

                SizedBox(height: 4.h),

                // --- QR GENERATOR BUTTON (Replaces old one) ---
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Text("Ready to hide clues?", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1565C0))),
                      SizedBox(height: 1.5.h),
                      SizedBox(
                        width: double.infinity,
                        height: 7.h,
                        child: ElevatedButton.icon(
                          onPressed: _generateAndPrintPdf,
                          icon: const Icon(Icons.print_rounded, color: Colors.white),
                          label: Text("Print All QR Codes (PDF)", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1565C0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text("Generates ${ _clueControllers.length} unique codes.", style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.blueGrey)),
                    ],
                  ),
                ),

                SizedBox(height: 4.h),

                // --- SAVE BUTTON ---
                SizedBox(
                  width: double.infinity, height: 6.5.h,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _saveHunt,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: state.isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Save & Publish Hunt", style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 5.h),
              ],
            ),
          ),
          if (state.isLoading) Container(color: Colors.black12, child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title) => Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w700, color: _textDark));
  Widget _buildLabel(String text) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: Text(text, style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w600, color: _textDark)));
  Widget _buildTextField(TextEditingController ctrl, String hint, {bool isNumber = false, int maxLines = 1}) => TextField(controller: ctrl, keyboardType: isNumber ? TextInputType.number : TextInputType.text, maxLines: maxLines, style: GoogleFonts.poppins(fontSize: 15.sp), decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.all(4.w), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border))));
  Widget _buildDropdown() => Container(padding: EdgeInsets.symmetric(horizontal: 4.w), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _difficulty, isExpanded: true, items: _difficultyLevels.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 15.sp)))).toList(), onChanged: (v) => setState(() => _difficulty = v!))));
}