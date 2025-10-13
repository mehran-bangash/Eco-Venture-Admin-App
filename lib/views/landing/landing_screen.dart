
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          body: Column(
            children: [
              // ================== HEADER ==================
              Stack(
                children: [
                  Container(
                    height: 32.h,
                    width: 100.w,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF2F5755),
                          Color(0xFF1A2A6C),
                          Color(0xFF000428),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      height: 34.h,
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
                        FadeInDown(
                          duration: const Duration(milliseconds: 700),
                          child: Container(
                            padding: EdgeInsets.all(2.5.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.public_rounded,
                              size: 7.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            "EcoVenture Admin Portal",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        FadeInUp(
                          duration: const Duration(milliseconds: 900),
                          child: Text(
                            "Empowering your eco-learning experience 🌍",
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ================== ROLE CARDS ==================
              Expanded(
                child: FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        RoleCard(
                          icon: Icons.child_care_rounded,
                          title: "Child",
                          subtitle: "Manage child accounts",
                          onTap: () => context.goNamed("bottomNavChild"),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB24592), Color(0xFFF15F79)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        RoleCard(
                          icon: Icons.escalator_warning_rounded,
                          title: "Parent",
                          subtitle: "Manage parent accounts",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF36D1DC), Color(0xFF5B86E5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        SizedBox(height: 2.5.h),
                        RoleCard(
                          icon: Icons.school_rounded,
                          title: "Teacher",
                          subtitle: "Manage teacher accounts",
                          gradient: const LinearGradient(
                            colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ================== FOOTER ==================
              FadeIn(
                duration: const Duration(milliseconds: 700),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: Text(
                    "© 2025 EcoVenture | All rights reserved",
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.h),
            ],
          ),
        );
      },
    );
  }
}

class RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Gradient gradient;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    required this.gradient,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.97 : 1.0),
        padding: EdgeInsets.all(3.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.h),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.85),
              Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.05 : 0.15),
              blurRadius: _isPressed ? 4 : 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.8.h),
              decoration: BoxDecoration(
                gradient: widget.gradient,
                borderRadius: BorderRadius.circular(1.8.h),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 5.h,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1E2F),
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
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
