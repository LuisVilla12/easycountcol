import 'package:easycoutcol/config/presentation/providers/theme_provider.dart';
import 'package:easycoutcol/config/router/app_router.dart';
import 'package:easycoutcol/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async{
  // Ejecutar el splash home cuando incio la app 
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); 

  //remover el splashome
  // FlutterNativeSplash.remove();
  
  // Habilita riverpodsen toda la aplicaición
  WidgetsFlutterBinding.ensureInitialized();
  runApp( 
    // Buscara todos  providers
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context,ref) {
    // Leer los valores del provider
    final selectedColor=ref.watch(selectedColorProvider);
    final isDarkmode=ref.watch(isDarkModeProvider);
    return MaterialApp.router(
      // Configurar router
      routerConfig: appRouter,
      // Quitar banner
      debugShowCheckedModeBanner: false,
      // colocar tme
      theme: AppTheme(selectedColor: selectedColor, isDarkmode: isDarkmode).getTheme(),
    );
  }
}
