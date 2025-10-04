import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ViewAllVideosScreen extends StatelessWidget {
  const ViewAllVideosScreen({super.key});

  final List<Map<String, String>> videos = const [
    {
      "title": "Flutter Basics Tutorial",
      "thumbnail": "https://img.youtube.com/vi/fq4N0hgOWzU/maxresdefault.jpg",
      "duration": "12:45"
    },
    {
      "title": "Advanced Firebase Integration",
      "thumbnail": "https://img.youtube.com/vi/9h3o5cVd0rM/maxresdefault.jpg",
      "duration": "08:30"
    },
    {
      "title": "Responsive UI in Flutter",
      "thumbnail": "https://img.youtube.com/vi/XxXyI2b2Dng/maxresdefault.jpg",
      "duration": "15:12"
    },
    {
      "title": "Flutter State Management (Provider)",
      "thumbnail": "https://img.youtube.com/vi/RlO3K6cWbLE/maxresdefault.jpg",
      "duration": "10:20"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Uploaded Videos"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(3.w),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return Container(
            margin: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    video["thumbnail"]!,
                    height: 20.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Info Section
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        video["title"]!,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Duration + Play Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer, size: 18, color: Colors.grey),
                              SizedBox(width: 1.w),
                              Text(
                                video["duration"]!,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.play_circle_fill,
                            color: Colors.blue.shade600,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
