import 'package:easycoutcol/config/presentation/screens/auth/login_screen.dart';
import 'package:easycoutcol/config/presentation/screens/auth/logout_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/config_screen.dart';
import 'package:easycoutcol/config/presentation/screens/follows/edit_follow_screen.dart';
import 'package:easycoutcol/config/presentation/screens/follows/add_follow_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/edit.screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/help_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/history_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/home_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/overlay_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/results_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/splash_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/theme_screen.dart';
import 'package:easycoutcol/config/presentation/screens/principal/tutorial_screen.dart';
import 'package:easycoutcol/config/presentation/screens/follows/follows_screen.dart';
import 'package:go_router/go_router.dart';

// Definir rutas
// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/tutorial',
  routes: [
    GoRoute(
      path: '/splash',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      name: TutorialScreen.name,
      builder: (context, state) => const TutorialScreen(),
    ),
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      name: HistoryScreen.name,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
        path: '/results:id',
        name: ResultsScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ResultsScreen(idMuestra: id);
        }),
    GoRoute(
      path: '/seguimientos',
      name: FollowsScreen.name,
      builder: (context, state) => const FollowsScreen(),
    ),
    GoRoute(
        path: '/editFollow:id',
        name: EditFollowScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditFollowScreen(idFollow: id);
        }),
    GoRoute(
        path: '/addFollow',
        name: AddFollowScreen.name,
        builder: (context, state) => const AddFollowScreen(),
        ),
    GoRoute(
      path: '/config',
      name: ConfigScreen.name,
      builder: (context, state) => ConfigScreen(),
    ),
    GoRoute(
      path: '/theme',
      name: ThemeScreen.name,
      builder: (context, state) => ThemeScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/logout',
      name: LogoutScreen.name,
      builder: (context, state) => const LogoutScreen(),
    ),
    GoRoute(
        path: '/editSample:id',
        name: EditSample.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditSample(idMuestra: id);
        }),
    GoRoute(
      path: '/overlay',
      name: OverlayScreen.name,
      builder: (context, state) => const OverlayScreen(),
    ),
    GoRoute(
      path: '/help',
      name: HelpScreen.name,
      builder: (context, state) => const HelpScreen(),
    ),
  ],
);