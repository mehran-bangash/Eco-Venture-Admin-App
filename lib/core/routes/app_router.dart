import 'package:go_router/go_router.dart';
import 'package:eco_venture_admin_portal/views/auth/login_screens.dart';
import 'package:eco_venture_admin_portal/views/auth/forgot_password_screen.dart';
import 'package:eco_venture_admin_portal/views/landing/landing_screen.dart';
import '../../views/settings/admin_settings.dart';
import '../../views/settings/settings_edit_profile_screen.dart';
import '../../views/settings/settings_profile_screen.dart';
import '../constants/route_names.dart';
import 'child_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.landing, // Default route
    routes: [
      GoRoute(
        path: RouteNames.landing,
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreens(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      //  Admin Settings Parent Route
      GoRoute(
        path: '/admin-settings',
        name: 'adminSettings',
        builder: (context, state) => const AdminSettings(),
        routes: [
          GoRoute(
            path: 'profile',
            name: 'adminProfile',
            builder: (context, state) => const SettingsProfileScreen(),
          ),
          GoRoute(
            path: 'edit-profile',
            name: 'editProfile',
            builder: (context, state) => const SettingsEditProfileScreen(),
          ),
        ],
      ),

      //  Include child routes
        ChildRouter.routes,
    ],
  );
}
