import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'edit_story_screen.dart';

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
        title: Text("Story Details"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditStoryScreen(
                    title: title,
                    thumbnail: thumbnail,
                    pages: pages,
                  ),
                ),
              );

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Edit '$title'")));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              // TODO: Add delete confirmation + Firebase delete
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(3.w),
              child: Image.network(
                thumbnail!,
                height: 30.h,
                width: 100.w,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 3.h),

            // Story Title
            Text(
              title!,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),

            // Story Info
            Row(
              children: [
                const Icon(Icons.book, color: Colors.grey),
                SizedBox(width: 2.w),
                Text(
                  "Total Pages: $pages",
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Dummy Story Preview
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
