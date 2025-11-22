import 'dart:async';
import 'package:eco_venture_admin_portal/views/child_section/widgets/Module_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AdminChildHome extends StatefulWidget {
  const AdminChildHome({super.key});

  @override
  State<AdminChildHome> createState() => _AdminChildHomeState();
}

class _AdminChildHomeState extends State<AdminChildHome> {
  final ScrollController _scrollController = ScrollController();
  late Timer _scrollTimer;

  final List<Map<String, dynamic>> _modules = [
    {
      "title": "Interactive Quiz",
      "subtitle": "Engaging knowledge tests",
      "colors": [Color(0xFF4CAF50), Color(0xFF81C784)],
    },
    {
      "title": "Multimedia Learning",
      "subtitle": "Videos and stories",
      "colors": [Color(0xFF42A5F5), Color(0xFF64B5F6)],
    },
    {
      "title": "Nature Photo Journal",
      "subtitle": "Visual documentation",
      "colors": [Color(0xFF7E57C2), Color(0xFF9575CD)],
    },
    {
      "title": "QR Treasure Hunt",
      "subtitle": "Interactive exploration",
      "colors": [Color(0xFFFFA726), Color(0xFFFFB74D)],
    },
    {
      "title": "STEM Challenges",
      "subtitle": "Science & Tech projects",
      "colors": [Color(0xFFE91E63), Color(0xFFF06292)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;
        double next = current + 1;
        if (next >= maxScroll) next = 0;
        _scrollController.jumpTo(next);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2F5755), Color(0xFF0A3431)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                SizedBox(height: 3.h),

                // Dashboard Summary Cards
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Wrap(
                    spacing: 3.w,
                    runSpacing: 2.h,
                    children: [
                      _buildDashboardCard(
                        title: "Total Children",
                        value: "125",
                        icon: Icons.people_alt_rounded,
                      ),
                      _buildDashboardCard(
                        title: "Modules Uploaded",
                        value: "25",
                        icon: Icons.folder_copy_rounded,
                      ),
                      _buildDashboardCard(
                        title: "Active Challenges",
                        value: "34",
                        icon: Icons.flag_rounded,
                      ),
                      _buildDashboardCard(
                        title: "Avg. Progress",
                        valueWidget: CircularPercentIndicator(
                          radius: 3.5.h,
                          lineWidth: 1.5.w,
                          percent: 0.78,
                          center: Text(
                            "78%",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          progressColor: Colors.amberAccent,
                          backgroundColor: Colors.white24,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        icon:  Icons.show_chart_rounded,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Auto Scrolling Modules Section
                Padding(
                  padding: EdgeInsets.only(left: 4.w, bottom: 1.h),
                  child: Text(
                    "Learning Modules",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _modules.length * 50,
                    itemBuilder: (context, index) {
                      final module = _modules[index % _modules.length];
                      return GestureDetector(
                        onTap: () {
                          switch (module['title']) {
                            case "Interactive Quiz":
                              context.goNamed("interactiveQuiz");
                              break;

                            case "Multimedia Learning":
                              context.goNamed('multiMediaContent');
                              break;

                            case "Nature photo journal":
                              // context.goNamed("naturePhotoJournal");
                              break;

                            case "QR Treasure Hunt":
                              // context.goNamed("qrTreasureHunt");
                              break;

                            case "STEM Challenges":
                               context.goNamed("stemChallengesScreen");
                              break;

                            default:
                              print("No route found");
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 3.w),
                          child: ModuleCard(
                            title: module['title'],
                            subtitle: module['subtitle'],
                            gradientColors: module['colors'].cast<Color>(),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 3.h),

                // Progress Overview
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    "Progress Overview",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                buildProgressCard(),

                // Reward Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    "Top Performers",
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildRewardCard(),

                SizedBox(height: 5.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Header Section
  Widget _buildHeaderSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Child Modules &\nProgress Dashboard",
            style: GoogleFonts.poppins(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              onPressed: () {
                context.goNamed('addModule');
              },
              icon: const Icon(Icons.add),
              label: Text(
                "Add New Module",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dashboard Card
  Widget _buildDashboardCard({
    required String title,
    String? value,
    Widget? valueWidget,
    required IconData icon,
  }) {
    return Container(
      width: 42.w,
      padding: EdgeInsets.all(2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.amberAccent, size: 25),
              SizedBox(width: 1.w),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          valueWidget ??
              Text(
                value ?? "--",
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
  }

  /// Progress Chart Card
  Widget buildProgressCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7E57C2), Color(0xFF5C6BC0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              child: Text(
                "Module completion rates across all children",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reward / Leaderboard Card
  Widget _buildRewardCard() {
    final topPerformers = [
      {"name": "Mehran A.", "points": "2310 pts", "rank": "1"},
      {"name": "Muhammad M.", "points": "2280 pts", "rank": "2"},
      {"name": "Ali A.", "points": "2150 pts", "rank": "3"},
      {"name": "Bangash K.", "points": "2090 pts", "rank": "4"},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Container(
        padding: EdgeInsets.all(2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.emoji_events, color: Colors.amberAccent, size: 40),
                SizedBox(width: 20),
                Icon(Icons.workspace_premium, color: Colors.white, size: 40),
                SizedBox(width: 20),
                Icon(Icons.star_rate, color: Colors.yellowAccent, size: 40),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              "Top 5 Children by Engagement",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            ...topPerformers
                .map(
                  (child) => _buildStudentRow(
                    child["name"]!,
                    child["points"]!,
                    child["rank"]!,
                  ),
                )
                ,
          ],
        ),
      ),
    );
  }

  Widget _buildStudentRow(String name, String points, String rank) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amberAccent,
                  radius: 18,
                  child: Text(
                    rank,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              points,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.amberAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
