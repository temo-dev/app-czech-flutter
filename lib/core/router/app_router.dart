import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../state/user/user_notifier.dart';
import '../../widgets/common/app_shell.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/nickname_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/placement/placement_test_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/course_map/course_map_screen.dart';
import '../../screens/lesson/lesson_screen.dart';
import '../../screens/review/review_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/media_feed/media_feed_screen.dart';
import '../../screens/community/community_screen.dart';
import '../../screens/classroom/classroom_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final user = ref.read(userProvider);
      final loc = state.matchedLocation;
      final isOnboarding = loc.startsWith('/onboarding');
      final isPlacement = loc.startsWith('/placement');
      final isAuth = loc.startsWith('/login') || loc.startsWith('/nickname');

      if (isAuth) return null; // auth screens always accessible
      if (!user.onboardingDone && !isOnboarding) return '/onboarding';
      if (user.onboardingDone && !user.placementDone && !isPlacement) return '/placement';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(redirectTo: state.extra as String?),
      ),
      GoRoute(
        path: '/nickname',
        builder: (context, state) => NicknameScreen(redirectTo: state.extra as String?),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/placement',
        builder: (context, state) => const PlacementTestScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/course', builder: (_, __) => const CourseMapScreen()),
          GoRoute(path: '/review', builder: (_, __) => const ReviewScreen()),
          GoRoute(path: '/media', builder: (_, __) => const MediaFeedScreen()),
          GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
          GoRoute(path: '/classroom', builder: (_, __) => const ClassroomScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/lesson/:lessonId',
        builder: (context, state) => LessonScreen(
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
    ],
  );
});
