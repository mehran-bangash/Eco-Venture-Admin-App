import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🌌 Elegant background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF141E30),
              Color(0xFF243B55),
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

                // ---------- ADD NEW STORY CARD ----------
                _buildFeatureCard(
                  title: "Add New Story",
                  subtitle: "Upload text or illustrated stories",
                  icon: Icons.auto_stories_rounded,
                  gradientColors: const [
                    Color(0xFF5C940D), // lush green
                    Color(0xFFB5E48C), // light lime
                  ],
                  accentColor: const Color(0xFFA3B18A),
                  onTap: () => context.goNamed('addStoryScreen'),
                ),

                SizedBox(height: 3.h),


                _buildFeatureCard(
                  title: "View All Stories",
                  subtitle: "Browse and manage uploaded stories",
                  icon: Icons.menu_book_rounded,
                  gradientColors: const [
                    Color(0xFF007F5F),
                    Color(0xFF2B9348),
                  ],
                  accentColor: const Color(0xFF55A630),
                  onTap: () => context.goNamed('viewAllStoriesScreen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Premium Card Widget (same as VideoScreen style)
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
                color: gradientColors.last.withOpacity(0.4),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // ✨ Top highlight overlay
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

              // 🔹 Card content
              Padding(
                padding: EdgeInsets.all(3.h),
                child: Row(
                  children: [
                    // Icon badge with subtle glow
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

                          // "Continue" chip
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
