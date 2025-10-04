import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF6F6F8), // background-light
          body: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: 30.h,
                    width: 100.w,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4F00BC), // purple
                          Color(0xFF2D0C57), // deep violet
                          Color(0xFF1A0A3A), // dark purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 32.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF4F00BC),
                            Color(0xFF2D0C57),
                            Color(0xFF1A0A3A),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.public,
                            size: 6.h,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Text(
                          "EcoVenture Admin Panel",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Place where we fix all problems",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                  child: ListView(
                    children: [
                      RoleCard(
                        icon: Icons.child_care,
                        title: "Child",
                        subtitle: "Manage child accounts",
                      ),
                      SizedBox(height: 2.h),
                      RoleCard(
                        icon: Icons.escalator_warning,
                        title: "Parent",
                        subtitle: "Manage parent accounts",
                      ),
                      SizedBox(height: 2.h),
                      RoleCard(
                        icon: Icons.school,
                        title: "Teacher",
                        subtitle: "Manage teacher accounts",
                      ),
                    ],
                  ),
                ),
              ),

              // ===== FOOTER =====
              Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Text(
                  "©2024 EcoVenture",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.h),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF4913EC).withOpacity(0.2), // primary
              borderRadius: BorderRadius.circular(1.5.h),
            ),
            child: Icon(
              icon,
              size: 5.h,
              color: const Color(0xFF4913EC), // primary color
            ),
          ),
          SizedBox(width: 4.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 60);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 120);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
