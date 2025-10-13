import 'package:eco_venture_admin_portal/views/auth/login_screens.dart';
import 'package:go_router/go_router.dart';

import '../../views/auth/forgot_password_screen.dart';
import '../../views/landing/landing_screen.dart';
import '../constants/route_names.dart';
import 'child_router.dart'; //  import your child router

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: RouteNames.login, // "/child"
    routes: [
      GoRoute(
        path: RouteNames.landing,
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => LoginScreens(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => ForgotPasswordScreen(),
      ),

      //  include the child section routes
      ChildRouter.routes,
    ],
  );
}
