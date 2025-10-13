import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ViewAllStoriesScreen extends StatelessWidget {
  const ViewAllStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stories = [
      {
        "title": "The Brave Lion",
        "thumbnail": "https://picsum.photos/200/300?random=1",
        "pages": 5,
      },
      {
        "title": "The Lost Jungle",
        "thumbnail": "https://picsum.photos/200/300?random=2",
        "pages": 8,
      },
      {
        "title": "Magical River",
        "thumbnail": "https://picsum.photos/200/300?random=3",
        "pages": 6,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.goNamed('multiMediaContent'),
          child: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("All Stories"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: EdgeInsets.all(3.w),
        child: ListView.builder(
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            return Card(
              margin: EdgeInsets.only(bottom: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(2.w),
                  child: Image.network(
                    story["thumbnail"],
                    width: 18.w,
                    height: 18.w,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  story["title"],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17.sp,
                  ),
                ),
                subtitle: Text(
                  "Pages: ${story["pages"]}",
                  style: TextStyle(fontSize: 15.sp),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),

                onTap: () {
                  context.goNamed(
                    'storyDetailScreen',
                    extra: story,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
