
import 'package:eco_venture_admin_portal/views/auth/login_screens.dart';
import 'package:go_router/go_router.dart';

import '../../views/auth/forgot_password_screen.dart';
import '../../views/landing/landing_screen.dart';
import '../constants/route_names.dart';


class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: RouteNames.login,
    routes: [
      // // Splash
      // GoRoute(
      //   path: RouteNames.splash,
      //   name: 'splash',
      //   builder: (context, state) => const SplashScreen(),
      // ),


      GoRoute(
        path: RouteNames.landing,
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),

      // Login
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) {
          // final role =state.extra as String?;
          return LoginScreens();
        },
      ),


      //forgot Password
      // Login
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      // // Child role routes
      // ChildRouter.routes,
      //
      // // Parent role routes
      // ParentRouter.routes,
      //
      // // Teacher role routes
      // TeacherRouter.routes,
    ],
  );
}
