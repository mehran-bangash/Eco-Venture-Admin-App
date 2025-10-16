import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:eco_venture_admin_portal/views/settings/widgets/edit_profile_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../core/utils/utils.dart';
import '../../services/shared_preferences_helper.dart';
import '../../viewmodels/admin_profile/admin_provider.dart';


class SettingsEditProfileScreen extends ConsumerStatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  ConsumerState<SettingsEditProfileScreen> createState() =>
      _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState
    extends ConsumerState<SettingsEditProfileScreen> {
  File? _image;
  final picker = ImagePicker();

  String username = "Guest";
  String userEmail = "";
  String profileImg = "";

  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  // Load cached values (name, email, image)
  Future<void> _loadSharedPreferences() async {
    final name = await SharedPreferencesHelper.instance.getAdminName();
    final email = await SharedPreferencesHelper.instance.getAdminEmail();
    final img = await SharedPreferencesHelper.instance.getAdminImgUrl();

    setState(() {
      username = name ?? "Guest";
      userEmail = email ?? "";
      profileImg = img ?? "";

      final parts = username.split(" ");
      _firstnameController.text = parts.isNotEmpty ? parts.first : "";
      _lastnameController.text =
      parts.length > 1 ? parts.sublist(1).join(" ") : "";
      _emailController.text = userEmail;
    });
  }

  // NEW: Sync only image URL directly from Firestore → SharedPreferences
  Future<void> _syncImageFromFirestore() async {
    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid == null) return;

    try {
      final doc =
      await FirebaseFirestore.instance.collection('Admins').doc(aid).get();

      if (doc.exists && doc.data() != null) {
        final imgUrl = doc.data()!['imageUrl'] ?? '';
        if (imgUrl.isNotEmpty) {
          await SharedPreferencesHelper.instance.saveAdminImgUrl(imgUrl);
          setState(() {
            profileImg = imgUrl;
          });
          debugPrint(" Synced Image URL from Firestore: $imgUrl");
        } else {
          debugPrint(" No image URL found in Firestore");
        }
      }
    } catch (e) {
      debugPrint(" Error syncing image from Firestore: $e");
    }
  }

  // Refresh button action
  Future<void> _refreshProfile() async {
    await _syncImageFromFirestore();
    await _loadSharedPreferences();
    Utils.showDelightToast(
      context,
      "Profile refreshed successfully",
      icon: Icons.check,
      autoDismiss: true,
      position: DelightSnackbarPosition.bottom,
      bgColor: Colors.green,
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // Pick image & upload to Cloudinary + Firestore
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) {
      Utils.showDelightToast(
        context,
        "No image selected",
        icon: Icons.image_not_supported,
        autoDismiss: true,
        position: DelightSnackbarPosition.top,
        bgColor: Colors.redAccent,
        textColor: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    setState(() => _image = File(pickedFile.path));

    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid != null && _image != null) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileImage(aid: aid, imageFile: _image!);

      // After uploading, sync image from Firestore
      await _syncImageFromFirestore();
      await _loadSharedPreferences();
      setState(() {});
    }
  }

  // Show gallery/camera bottom sheet
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Option",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      height: 8.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.photo, size: 10.w, color: Colors.blue),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      height: 8.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Save button logic
  Future<void> _saveProfile() async {
    final firstName = _firstnameController.text.trim();
    final lastName = _lastnameController.text.trim();
    final fullName = "$firstName $lastName".trim();
    final aid = await SharedPreferencesHelper.instance.getAdminId();
    if (aid == null) return;

    if (_image != null) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileImage(aid: aid, imageFile: _image!);
    }

    if (fullName != username) {
      await ref
          .read(adminProfileProviderNew.notifier)
          .uploadAndSaveProfileName(aid: aid, name: fullName);
    }

    await _syncImageFromFirestore();
    await _loadSharedPreferences();

    Utils.showDelightToast(
      context,
      "Profile updated successfully",
      icon: Icons.check,
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      bgColor: Colors.green,
      textColor: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProfileProviderNew);
    final admin = adminState.adminProfile;
    final effectiveImgUrl = admin?.imgUrl.isNotEmpty == true
        ? admin!.imgUrl
        : profileImg;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 22.h,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.backgroundGradient,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, top: 3.h, right: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              context.goNamed('adminProfile');
                            },
                            child: _topIcon(Icons.arrow_back_ios_new),
                          ),
                          GestureDetector(
                            onTap: _refreshProfile,
                            child: _topIcon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: _showImagePickerOptions,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.blueGrey.shade200,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : (effectiveImgUrl.isNotEmpty
                            ? NetworkImage(effectiveImgUrl)
                            : null),
                        child: (_image == null && effectiveImgUrl.isEmpty)
                            ? Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : "?",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : null,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Edit Profile",
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---- Body ----
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  _buildLabel("Full Name"),
                  EditProfileTextField(
                    controller: _firstnameController,
                    icon: Icons.person,
                    hintText: "First Name",
                  ),
                  SizedBox(height: 1.h),
                  EditProfileTextField(
                    controller: _lastnameController,
                    icon: Icons.person,
                    hintText: "Last Name",
                  ),
                  _buildLabel("Email (not Editable)"),
                  EditProfileTextField(
                    controller: _emailController,
                    icon: Icons.email,
                    hintText: "Email",
                    readOnly: true,
                  ),
                  SizedBox(height: 5.h),
                  GestureDetector(
                    onTap: () async {
                      await _saveProfile();
                      final image = await SharedPreferencesHelper.instance
                          .getAdminImgUrl();
                      print("🟢 Image from SharedPreferences: $image");
                    },
                    child: Container(
                      height: 7.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (adminState.isLoading)
                              const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            else
                              const Icon(Icons.save,
                                  color: Colors.white, size: 22),
                            SizedBox(width: 2.w),
                            Text(
                              "Save Changes",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon(IconData icon) {
    return Container(
      height: 4.h,
      width: 8.w,
      decoration: BoxDecoration(
        color: Colors.white70.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}
