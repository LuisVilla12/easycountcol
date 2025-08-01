import 'package:easycoutcol/config/presentation/screens/auth/login_screen.dart';
import 'package:easycoutcol/config/presentation/screens/auth/logout_screen.dart';
import 'package:easycoutcol/config/presentation/screens/config_screen.dart';
import 'package:easycoutcol/config/presentation/screens/edit.screen.dart';
import 'package:easycoutcol/config/presentation/screens/help_screen.dart';
import 'package:easycoutcol/config/presentation/screens/history_screen.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/screens/overlay_screen.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:easycoutcol/config/presentation/screens/splash_screen.dart';
import 'package:easycoutcol/config/presentation/screens/theme_screen.dart';
import 'package:easycoutcol/config/presentation/screens/tutorial_screen.dart';
import 'package:go_router/go_router.dart';

// Definir rutas
// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/home',
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