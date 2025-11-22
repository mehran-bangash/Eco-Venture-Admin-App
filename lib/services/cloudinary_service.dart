import 'dart:convert';
import 'dart:io';
import 'package:eco_venture_admin_portal/services/shared_preferences_helper.dart';
import 'package:http/http.dart' as http;


class CloudinaryService {
  final String cloudName = "dosvc174j";
  final String secondCloudName = 'dlgtmxbjn'; // Defined for profile images
  final String uploadPreset = "flutter_unsigned_preset";
  final String profileUploadPreset = 'profile_pic_preset'; // Defined for profile images

  // --- NEW: Function to upload images for STEM Challenges ---
  Future<String?> uploadStemImage(File file, {required String category}) async {
    try {
      // 1. Get Admin ID from SharedPreferences
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';

      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      // Folder structure: Admin/admin_id/stem/category_name
      final folderPath = "Admin/$adminUid/stem/$category";

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..fields["folder"] = folderPath
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print("Cloudinary STEM Image Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading STEM image to Cloudinary: $e");
      return null;
    }
  }

  // --- EXISTING FUNCTIONS ---

  Future<String?> uploadQuizImage(File file, {required String category}) async {
    try {
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final folderPath = "Admin/$adminUid/quizzes/$category";

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..fields["folder"] = folderPath
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print("Cloudinary Quiz Image Upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading Quiz image to Cloudinary: $e");
      return null;
    }
  }

  Future<String?> uploadFile(File file, {required bool isVideo}) async {
    try {
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';
      final uploadType = isVideo ? "video" : "image";
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/$uploadType/upload");

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

  Future<String?> uploadImage(File file) async {
    try {
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = "flutter_story_preset"
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

  Future<String?> uploadProfileImage(File file) async {
    try {
      final adminUid = await SharedPreferencesHelper.instance.getAdminId() ?? 'unknown_admin';
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$secondCloudName/image/upload");

      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = profileUploadPreset
        ..fields["folder"] = "Admin/$adminUid/profile"
        ..files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final res = await http.Response.fromStream(response);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data["secure_url"];
      } else {
        print("Profile image upload failed: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      return null;
    }
  }
}