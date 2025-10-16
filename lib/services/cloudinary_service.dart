import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName = "dosvc174j"; // your Cloudinary cloud name   mehran.sit88@gmail.com for video and story
  final String secondCloudName = 'dlgtmxbjn';  // testbusiness199@gamil.com for profile image
  final String profileUploadPreset = 'profile_pic_preset';  //
  final String uploadPreset = "flutter_unsigned_preset"; // for videos/images
  final String storyUploadPreset = "flutter_story_preset"; // for story images
  final FirebaseAuth _auth = FirebaseAuth.instance;




  //  Upload video or thumbnail
  Future<String?> uploadFile(File file, {required bool isVideo}) async {
    try {
      final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';
      final uploadType = isVideo ? "video" : "image";

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$uploadType/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..fields["folder"] = "Admin/$adminUid/videos"
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print("Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print(" Error uploading to Cloudinary: $e");
      return null;
    }
  }

  //  Upload story image or thumbnail
  Future<String?> uploadImage(File file) async {
    try {
      final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = storyUploadPreset
        ..fields["folder"] = "Admin/$adminUid/stories"
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print(" Story upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print(" Error uploading story image: $e");
      return null;
    }
  }
  //  Upload  Profile image
  Future<String?> uploadProfileImage(File file) async {
    try {
      final adminUid = _auth.currentUser?.uid ?? 'unknown_admin';

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$secondCloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = profileUploadPreset
        ..fields["folder"] = "Admin/$adminUid/profile"  // Consistent folder
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print("Profile image upload failed: ${res.body}");  // Correct error message
        return null;
      }
    } catch (e) {
      print("Error uploading profile image: $e");  // Correct error message
      return null;
    }
  }
}
