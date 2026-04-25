import 'package:easycoutcol/config/presentation/providers/conexion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerWidget {
  static const String name = 'splash_screen';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncConnection = ref.watch(conexionProvider);
    print(asyncConnection);
    return asyncConnection.when(
  loading: () => const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  ),
  error: (err, _) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Error al conectar con el servidor'),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => ref.refresh(conexionProvider),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  ),
  data: (connected) {
    // Remover splash tan pronto se obtiene la respuesta
    FlutterNativeSplash.remove();
    if (connected) {
      Future.microtask(() => context.go('/tutorial'));
    }

    // Si no está conectado, mostrar mensaje de error y botón de reintentar
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No hay conexión con el servidor'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => ref.refresh(conexionProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  },
);
  }
  }