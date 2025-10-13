import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class StoryDetailScreen extends StatelessWidget {
  final String? title;
  final String? thumbnail;
  final int? pages;

  const StoryDetailScreen({
    super.key,
    this.title,
    this.thumbnail,
    this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Details"),
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
            child: Icon(Icons.arrow_back)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          /// EDIT BUTTON → Navigates to EditStoryScreen
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // Using GoRouter for navigation
              context.goNamed(
                'editStoryScreen',
                extra: {
                  "title": title,
                  "thumbnail": thumbnail,
                  "pages": pages,
                },
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Editing '$title'...")),
              );
            },
          ),

          ///  DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Story"),
                  content: Text("Are you sure you want to delete '$title'?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Deleted '$title'")),
                        );
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),

      ///  BODY SECTION
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///  Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: Image.network(
                thumbnail ?? "",
                height: 30.h,
                width: 100.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            ),
            SizedBox(height: 3.h),

            /// Title
            Text(
              title ?? "Untitled Story",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),

            ///  Pages Info
            Row(
              children: [
                const Icon(Icons.book, color: Colors.grey),
                SizedBox(width: 2.w),
                Text(
                  "Total Pages: ${pages ?? 0}",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            ///  Story Preview
            Text(
              "Preview:",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 1.h),
            Text(
              "Once upon a time in a magical forest, there lived a brave lion who wanted to protect his friends...",
              style: TextStyle(fontSize: 16.sp, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
