import 'package:easycoutcol/config/router/app_router.dart';
import 'package:easycoutcol/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configurar router
      routerConfig: appRouter,
      // Quitar banner
      debugShowCheckedModeBanner: false,
      // colocar tme
      theme: AppTheme(selectedColor: 4).getTheme(),
    );
  }
}
