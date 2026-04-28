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
import 'package:easycoutcol/config/presentation/screens/records/add_record_screen.dart';
import 'package:easycoutcol/config/presentation/screens/records/records_screen.dart';
import 'package:easycoutcol/config/presentation/screens/records/show_record_screen.dart';
import 'package:easycoutcol/config/presentation/screens/records/graph_record_screen.dart';
import 'package:easycoutcol/config/presentation/screens/records/edit_record_screen.dart';

import 'package:go_router/go_router.dart';

// Definir rutas
final appRouter = GoRouter(
  initialLocation: '/login',
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
    // Editar un seguimiento
    GoRoute(
        path: '/editFollow:id',
        name: EditFollowScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditFollowScreen(idFollow: id);
        }),
    //Ver los records que tiene un follow
    GoRoute(
        path: '/follows/records:id',
        name: RecordsScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return RecordsScreen(followID: id);
        }),
    //Crear un nuevo seguimiento
    GoRoute(
      path: '/add-Follow',
      name: AddFollowScreen.name,
      builder: (context, state) => const AddFollowScreen(),
    ),
    //Registrar records al follows
    GoRoute(
        path: '/add_record:id',
        name: AddRecordScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return AddRecordScreen(followID: id);
        }),
    GoRoute(
        path: '/show/record/results:id',
        name: ShowRecordScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ShowRecordScreen(idMuestra: id);
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
    GoRoute(
        path: '/graph/follows:id',
        name: GraphRecordScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return GraphRecordScreen(followID: id);
        }),
    GoRoute(
        path: '/editRecord:id',
        name: EditRecordScreen.name,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditRecordScreen(idRecord: id);
        }),
  ],
);
