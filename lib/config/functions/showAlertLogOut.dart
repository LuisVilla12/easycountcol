import 'package:easycoutcol/config/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showAlertLogOut(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(), // Cierra solo el diálogo
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.of(context).pop(); // Cierra el diálogo
            context.goNamed(LoginScreen.name); // Redirige al login
          },
          child: const Text('Sí, cerrar sesión'),
        ),
      ],
    ),
  );
}
