import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditStoryScreen extends StatefulWidget {
  final String? title;
  final String? thumbnail;
  final int? pages;

  const EditStoryScreen({
    super.key,
     this.title,
     this.thumbnail,
     this.pages,
  });

  @override
  State<EditStoryScreen> createState() => _EditStoryScreenState();
}

class _EditStoryScreenState extends State<EditStoryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _thumbnailController;
  late TextEditingController _pagesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _thumbnailController = TextEditingController(text: widget.thumbnail);
    _pagesController = TextEditingController(text: widget.pages.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _thumbnailController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  void _saveStory() {
    // TODO: Later connect with Firebase update logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Story '${_titleController.text}' updated successfully!"),
      ),
    );
    Navigator.pop(context); // Go back to detail screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Story"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Input
              Text("Story Title", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 1.h),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter story title",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 3.h),

              // Thumbnail Input
              Text("Thumbnail URL", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 1.h),
              TextField(
                controller: _thumbnailController,
                decoration: InputDecoration(
                  hintText: "Enter thumbnail image URL",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 3.h),

              // Pages Input
              Text("Total Pages", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 1.h),
              TextField(
                controller: _pagesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter number of pages",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 5.h),

              // Save Button
              SizedBox(
                width: 100.w,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveStory,
                  child: Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 17.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
