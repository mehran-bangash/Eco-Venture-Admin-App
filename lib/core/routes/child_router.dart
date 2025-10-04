import 'package:eco_venture_admin_portal/views/child_section/admin_child_home.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/add_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/add_video_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/edit_story_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/multimedia_content_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/story_detail_screen.dart';
import 'package:eco_venture_admin_portal/views/child_section/multimedia_content/view_all_stories_screen.dart';
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
    builder: (context, state) =>
        const BottomNavChild(), // wrap with your nav container
    routes: [
      // GoRoute(
      //     path: 'child-profile',
      //     name: 'childProfile',
      //     builder: (context, state) => const ChildProfile(),
      //     routes: [
      //       GoRoute(
      //         path: 'edit-profile',
      //         name: 'editProfile',
      //         builder: (context, state) => const EditProfileScreen(),
      //       )
      //     ]
      // ),
      // GoRoute(
      //   path: 'child-settings',
      //   name: 'childSettings',
      //   builder: (context, state) =>const ChildSettings(),
      // ),
      GoRoute(
        path: 'home', //  relative path, not /child/home
        name: 'childHome',
        builder: (context, state) => const AdminChildHome(),
        routes: [
          GoRoute(
            path: 'treasure-hunt',
            name: 'treasureHunt',
            builder: (context, state) => const TreasureHuntScreen(),
          ),
          GoRoute(
            path: 'multimedia-content',
            name: 'multiMediaContent',
            builder: (context, state) => const MultimediaContentScreen(),
            routes: [
              GoRoute(
                path: 'video-screen',
                name: 'videoScreen',
                builder: (context, state) => const VideoScreen(),
                routes: [
                  GoRoute(
                    path: 'add-video-screen',
                    name: 'addVideoScreen',
                    builder: (context, state) => const AddVideoScreen(),
                  ),
                  GoRoute(
                    path: 'view-all-videos-screen',
                    name: 'ViewAllVideosScreen',
                    builder: (context, state) => const ViewAllStoriesScreen(),
                  ),
                ],
              ),
              GoRoute(
                path: 'story-screen',
                name: 'storyScreen',
                builder: (context, state) => const StoryScreen(),
                routes: [
                  GoRoute(
                    path: 'add-story-screen',
                    name: 'addStoryScreen',
                    builder: (context, state) => const AddStoryScreen(),
                  ),
                  GoRoute(
                    path: 'view-all-stories-screen',
                    name: 'viewAllStoriesScreen',
                    builder: (context, state) => const ViewAllStoriesScreen(),
                    routes: [
                      GoRoute(
                        path: 'story-detail-screen',
                        name: 'storyDetailScreen',
                        builder: (context, state) {
                          final extras =
                              state.extra as Map<String, dynamic>? ?? {};
                          return StoryDetailScreen(
                            title: extras['title'] as String?,
                            thumbnail: extras['thumbnail'] as String?,
                            pages: extras['pages'] as int?,
                          );
                        },
                      ),
                      GoRoute(
                        path: 'edit-story-screen',
                        name: 'editStoryScreen',
                        builder: (context, state) {
                          final extras =
                              state.extra as Map<String, dynamic>? ?? {};
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
            path: 'stem-challenges',
            name: 'stemChallenges',
            builder: (context, state) => const StemChallengesScreen(),
          ),
          GoRoute(
            path: 'nature-photo-journal',
            name: 'naturePhotoJournal',
            builder: (context, state) => const NaturePhotoJournalScreen(),
          ),

          GoRoute(
            path: 'interactive-quiz',
            name: 'interactiveQuiz',
            builder: (context, state) => const InteractiveQuizScreen(),
          ),
        ],
      ),
    ],
  );
}
