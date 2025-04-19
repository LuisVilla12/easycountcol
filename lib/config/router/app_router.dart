import 'package:easycoutcol/config/presentation/screens/config_screen.dart';
import 'package:easycoutcol/config/presentation/screens/history_screen.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/screens/login_screen.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:easycoutcol/config/presentation/screens/tutorial_screen.dart';
import 'package:go_router/go_router.dart';

// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/tutorial',
  routes: [
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      name: TutorialScreen.name,
      builder: (context, state) => TutorialScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/history',
      name: HistoryScreen.name,
      builder: (context, state) => HistoryScreen(),
    ),
    GoRoute(
      path: '/results',
      name: ResultsScreen.name,
      builder: (context, state) => ResultsScreen(),
    ),
    GoRoute(
      path: '/config',
      name: ConfigScreen.name,
      builder: (context, state) => ConfigScreen(),
    ),
  ],
);