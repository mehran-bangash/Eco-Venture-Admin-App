import 'package:eco_venture_admin_portal/core/constants/app_colors.dart';
import 'package:eco_venture_admin_portal/views/child_section/widgets/Module_card.dart';
import 'package:eco_venture_admin_portal/views/child_section/widgets/dashboard_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AdminChildHome extends StatefulWidget {
  const AdminChildHome({super.key});

  @override
  State<AdminChildHome> createState() => _AdminChildHomeState();
}

class _AdminChildHomeState extends State<AdminChildHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Header Section
              _buildHeaderSection(),
              SizedBox(height: 5.h),
              Row(
                children: [
                  DashboardCard(
                    title: "Total Children",
                    content: Text(
                      "125",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  DashboardCard(
                    title: "Modules Uploaded",
                    content: Text(
                      "25",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  DashboardCard(
                    title: "Average Progress",
                    content: CircularPercentIndicator(
                      radius: 40.0, // controls exact size
                      lineWidth: 9.0,
                      percent: 0.78,
                      center: Text(
                        "78%",
                        style: GoogleFonts.poppins(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      progressColor: AppColors.primaryBlue,
                      backgroundColor: Colors.grey.shade300,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                    ),
                  ),
                  DashboardCard(
                    title: "Active Challenges",
                    content: Text(
                      "34",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              // Existing ones
              ModuleCard(
                title: "Interactive Quiz",
                subtitle: "Engaging knowledge tests",
                gradientColors: [Colors.green, Colors.lightGreen],
              ),

              ModuleCard(
                title: "Multimedia Learning",
                subtitle: "video and story",
                gradientColors: [Colors.blue, Colors.lightBlueAccent],
              ),

              ModuleCard(
                title: "Nature photo journal",
                subtitle: "visual documentation",
                gradientColors: [Colors.deepPurple, Colors.purpleAccent],
              ),

              ModuleCard(
                title: "QR Treasure Hunt",
                subtitle: "interactive exploration ",
                gradientColors: [Colors.orange, Colors.deepOrangeAccent],
              ),

              ModuleCard(
                title: "STEM Challenges",
                subtitle: "Science & teach projects",
                gradientColors: [Colors.pink, Colors.redAccent],
              ),
              // Progress Overview
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Progress Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              buildProgressCard(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "Rewards and Gamification",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              _buildRewardCard(),
              SizedBox(height: 5.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardCard() {
    return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Container(
                height: 40.h,
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2196F3), // Blue
                      Color(0xFF0D47A1), // Navy Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white, // Only bottom border color
                          width: 2,          // Thickness
                        ),
                    ),),
                    child: Padding(
                      padding:  EdgeInsets.only(top: 2.h,left: 10.w,bottom: 1.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.yellow, size: 10.w), // Trophy
                          SizedBox(width: 10.w),
                          Icon(Icons.verified, color: Colors.white, size: 10.w), // Badge
                          SizedBox(width: 10.w),
                          Icon(Icons.eco, color: Colors.green, size: 10.w), // Leaf
                          SizedBox(width: 10.w),
                          Icon(Icons.local_fire_department, color: Colors.red, size: 10.w), // Fire
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h,),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Top 5 children by engagement ",
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  _buildStudentRow("Mehran A.", "2310 pts", "2"),
                  _buildStudentRow("Muhammad M.", "2280 pts", "3"),
                  _buildStudentRow("ALi A.", "2150 pts", "4"),
                  _buildStudentRow("Bangash K.", "2090 pts", "5"),
                ],),
              ),
            );
  }

  Widget buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart
            SizedBox(
              height: 20.h,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: Colors.purpleAccent,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 7,
                          color: Colors.blueAccent,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 3,
                          color: Colors.greenAccent,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: Colors.orangeAccent,
                          width: 22,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 4,
                          color: Colors.redAccent,
                          width: 22,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            Center(
              child: Container(
                width: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(width: 1, color: Colors.white),
                ),
                child: Text(
                  "Module completion rates across all children",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 2.w),
          child: Text(
            "Child Modules & \nprogress",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.background,
            ),
          ),
        ),
        SizedBox(width: 13.w),
        Container(
          height: 5.h,
          width: 25.w,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 1.5.w, top: 1.h),
                child: Icon(Icons.library_add),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.only(left: 1.5.w, top: 1.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add new Module",
                      style: GoogleFonts.poppins(
                        letterSpacing: 0.2,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 1.5.w),
        Expanded(
          child: Container(
            height: 7.h,
            width: 25.w,
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: 1.w),
      ],
    );
  }
}
Widget _buildStudentRow(String name, String points, String rank) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 1.h,horizontal: 4.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: Text(rank,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
            ),
            SizedBox(width: 2.w),
            Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
        Text(
          points,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.yellowAccent,
          ),
        ),
      ],
    ),
  );
}
