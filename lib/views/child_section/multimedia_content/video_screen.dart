import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 5.h),
                _buildFeatureCard(
                  title: "Add New Video",
                  subtitle: "Upload MP4 or YouTube link",
                  icon: Icons.video_call_rounded,
                  gradientColors: const [
                    Color(0xFF5A189A), // deep purple
                    Color(0xFF9D4EDD), // rich violet
                  ],
                  accentColor: const Color(0xFFC77DFF),
                  onTap: () => context.goNamed('addVideoScreen'),
                ),

                SizedBox(height: 3.h),

                _buildFeatureCard(
                  title: "View All Videos",
                  subtitle: "Repository & video statuses",
                  icon: Icons.video_library_rounded,
                  gradientColors: const [
                    Color(0xFF0077B6),
                    Color(0xFF00B4D8),
                  ],
                  accentColor: const Color(0xFF90E0EF),
                  onTap: () => context.goNamed('viewAllVideosScreen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradientColors,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 23.h,
          width: 100.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors.last.withOpacity(0.45),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 100.w,
                  height: 10.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(22),
                      bottomLeft: Radius.circular(100),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(3.h),
                child: Row(
                  children: [

                    Container(
                      height: 8.h,
                      width: 8.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),

                    SizedBox(width: 4.w),

                    // Text Section
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            subtitle,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          SizedBox(height: 2.h),

                          // "Continue" button chip
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  "Continue",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
