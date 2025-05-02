import 'package:easycoutcol/config/presentation/screens/auth/login_screen.dart';
import 'package:easycoutcol/config/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  static String name = 'logout_screen';

  const LogoutScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    final sharedDatosUsuario = await SharedPreferences.getInstance();
    await sharedDatosUsuario.clear();
    context.goNamed(LoginScreen.name); // Redirige al login
  }

  void _mostrarAlerta(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              context.pushNamed(HomeScreen.name);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _cerrarSesion(context),
            child: const Text('Sí, cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors=Theme.of(context).colorScheme;
    // Espera al primer frame para mostrar el diálogo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mostrarAlerta(context);
    });

    // Retorna algo mínimo para evitar pantalla negra
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.shrink(),
    );
  }
}
