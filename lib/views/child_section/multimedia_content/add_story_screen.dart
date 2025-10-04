import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddStoryScreen extends StatefulWidget {
  const AddStoryScreen({super.key});

  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<Map<String, String>> _storyPages = [];

  void _addPage() {
    setState(() {
      _storyPages.add({"text": "", "image": ""});
    });
  }

  void _removePage(int index) {
    setState(() {
      _storyPages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Story"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story Title
            Text("Story Title", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: "Enter story title",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 3.h),

            // Cover Thumbnail
            Text("Thumbnail Image", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 1.h),
            Container(
              height: 20.h,
              width: 100.w,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Add image picker
                  },
                  icon: Icon(Icons.image),
                  label: Text("Upload Thumbnail"),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Story Pages
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Story Pages", style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: _addPage,
                  icon: Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 1.h),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _storyPages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Story Text
                        TextField(
                          onChanged: (val) => _storyPages[index]["text"] = val,
                          decoration: InputDecoration(
                            labelText: "Page ${index + 1} Text",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: 2.h),

                        // Story Image
                        Container(
                          height: 18.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: () {
                                // TODO: Add image picker
                              },
                              icon: Icon(Icons.image),
                              label: Text("Upload Page Image"),
                            ),
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Remove Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () => _removePage(index),
                            icon: Icon(Icons.delete, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 3.h),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Upload to Firebase later
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Story Added (dummy for now)")),
                  );
                },
                icon: Icon(Icons.cloud_upload),
                label: Text("Upload Story"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
