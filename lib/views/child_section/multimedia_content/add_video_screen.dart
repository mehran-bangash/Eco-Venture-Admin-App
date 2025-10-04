import 'package:eco_venture_admin_portal/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  // Placeholder for picked files
  String? thumbnailPath;
  String? videoPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.arrow_back_ios_new,color: Colors.white,),
        title: Text(
          "Add New Video",
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Video Title",
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Thumbnail Picker
            GestureDetector(
              onTap: () {
                // TODO: Pick Thumbnail
              },
              child: Container(
                height: 20.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: thumbnailPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.image, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Upload Thumbnail"),
                        ],
                      )
                    : Image.network(thumbnailPath!, fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 3.h),

            // Video Picker
            GestureDetector(
              onTap: () {
                // TODO: Pick Video
              },
              child: Container(
                height: 15.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: videoPath == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.video_library,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text("Upload Video"),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 10),
                          Text("Video Selected"),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 3.h),

            // Video Duration
            TextField(
              controller: _durationController,
              decoration: InputDecoration(
                labelText: "Video Duration (e.g. 3:45)",
                prefixIcon: const Icon(Icons.timer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 5.h),

            // Upload Button
            Center(
              child: SizedBox(
                width: 80.w,
                height: 7.h,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.cloud_upload, color: Colors.white),
                  label:  Text(
                    "Upload Video",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.background,),
                  ),
                  onPressed: () {
                    // TODO: Upload logic
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
