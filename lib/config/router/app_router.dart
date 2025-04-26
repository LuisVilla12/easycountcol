import 'package:easycoutcol/config/presentation/screens/auth/demo_new_user_screen.dart';
import 'package:easycoutcol/config/presentation/screens/auth/login_screen.dart';
import 'package:easycoutcol/config/presentation/screens/config_screen.dart';
import 'package:easycoutcol/config/presentation/screens/history_screen.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/screens/results_screen.dart';
import 'package:easycoutcol/config/presentation/screens/tutorial_screen.dart';
import 'package:go_router/go_router.dart';

// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
     GoRoute(
      path: '/tutorial',
      name: TutorialScreen.name,
      builder: (context, state) => TutorialScreen(),
    ),
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      name: HistoryScreen.name,
      builder: (context, state) => HistoryScreen(),
    ),
    GoRoute(
      path: '/results:id',
      name: ResultsScreen.name,
      builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ResultsScreen(idMuestra: id); 
      }
    ),
    GoRoute(
      path: '/config',
      name: ConfigScreen.name,
      builder: (context, state) => ConfigScreen(),
    ),
    GoRoute(
      path: '/login:id',
      name: LoginScreen.name,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/new-user',
      name: NewUserScreen.name,
      builder: (context, state) => NewUserScreen(),
    ),
  ],
);