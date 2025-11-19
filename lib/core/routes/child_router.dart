import 'package:eco_venture_admin_portal/models/quiz_model.dart';
import 'package:eco_venture_admin_portal/views/child_section/admin_child_home.dart';
import 'package:eco_venture_admin_portal/views/child_section/interactive_quiz_screen/add_quiz_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/interactive_quiz_screen/edit_quiz_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/add_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/add_video_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/edit_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/multimedia_content_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/story_detail_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/view_all_stories_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/view_all_videos_screen.dart';
import 'package:go_router/go_router.dart';

import '../../navigation/bottom_nav_child.dart';
import '../../views/child_section/ stem_challenges_screen/stem_challenges_screen.dart';
import '../../views/child_section/interactive_quiz_screen/interactive_quiz_screen.dart';
import '../../views/child_section/multimedia_content/story_screen.dart';
import '../../views/child_section/multimedia_content/video_screen.dart';
import '../../views/child_section/nature_photo_journal_screen/nature_photo_journal_screen.dart';
import '../../views/child_section/treasure_hunt/treasure_hunt_screen.dart';
import '../constants/route_names.dart';
class ChildRouter {
  static final routes = GoRoute(
    path: RouteNames.bottomNavChild, // "/child"
    name: 'bottomNavChild',
    builder: (context, state) => const BottomNavChild(),
    routes: [
      GoRoute(
        path: RouteNames.childHome, // "/child/home"
        name: 'childHome',
        builder: (context, state) => const AdminChildHome(),
        routes: [
          GoRoute(
            path: RouteNames.treasureHunt,
            name: 'treasureHunt',
            builder: (context, state) => const TreasureHuntScreen(),
          ),
          GoRoute(
            path: RouteNames.multiMediaContent,
            name: 'multiMediaContent',
            builder: (context, state) => const MultimediaContentScreen(),
            routes: [
              GoRoute(
                path: RouteNames.videoScreen,
                name: 'videoScreen',
                builder: (context, state) => const VideoScreen(),
                routes: [
                  GoRoute(
                    path: RouteNames.addVideoScreen,
                    name: 'addVideoScreen',
                    builder: (context, state) => const AddVideoScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.viewAllVideosScreen,
                    name: 'viewAllVideosScreen',
                    builder: (context, state) => const ViewAllVideosScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: RouteNames.storyScreen,
                name: 'storyScreen',
                builder: (context, state) => const StoryScreen(),
                routes: [
                  GoRoute(
                    path: RouteNames.addStoryScreen,
                    name: 'addStoryScreen',
                    builder: (context, state) => const AddStoryScreen(),
                  ),
                  GoRoute(
                    path: RouteNames.viewAllStoriesScreen,
                    name: 'viewAllStoriesScreen',
                    builder: (context, state) => const ViewAllStoriesScreen(),
                    routes: [
                      GoRoute(
                        path: RouteNames.storyDetailScreen,
                        name: 'storyDetailScreen',
                        builder: (context, state) {
                          final extras = state.extra as Map<String, dynamic>? ?? {};
                          return StoryDetailScreen(
                            title: extras['title'] as String?,
                            thumbnail: extras['thumbnail'] as String?,
                            pages: extras['pages'] as int?,
                          );
                        },
                      ),
                      GoRoute(
                        path: RouteNames.editStoryScreen,
                        name: 'editStoryScreen',
                        builder: (context, state) {
                          final extras = state.extra as Map<String, dynamic>? ?? {};
                          return EditStoryScreen(
                            title: extras['title'] as String?,
                            thumbnail: extras['thumbnail'] as String?,
                            pages: extras['pages'] as int?,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.stemChallenges,
            name: 'stemChallenges',
            builder: (context, state) => const StemChallengesScreen(),
          ),
          GoRoute(
            path: RouteNames.naturePhotoJournal,
            name: 'naturePhotoJournal',
            builder: (context, state) => const NaturePhotoJournalScreen(),
          ),
          GoRoute(
            path: RouteNames.interactiveQuiz,
            name: 'interactiveQuiz',
            builder: (context, state) => const InteractiveQuizScreen(),
            routes: [
              GoRoute(
                path: RouteNames.addQuizScreen,
                name: 'addQuizScreen',
                builder: (context, state) => const AddQuizScreen(),
              ),
              GoRoute(
                path: RouteNames.editQuizScreen,
                name: 'editQuizScreen',
                builder: (context, state) {
                  final quizData = state.extra as QuizModel;
                  return EditQuizScreen(quizData: quizData);
                },
              ),

            ],
          ),
        ],
      ),
    ],
  );
}
