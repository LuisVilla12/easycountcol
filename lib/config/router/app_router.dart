import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:easycoutcol/config/presentation/screens/tutorial_screen.dart';
import 'package:go_router/go_router.dart';

// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/tutorial',
  routes: [
    GoRoute(
      path: '/',
      name: HomeScreen.name,
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => TutorialScreen(),
    ),
  ],
);