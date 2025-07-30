import 'package:easycoutcol/config/presentation/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConfigScreen extends ConsumerWidget {
  static const String name='config_name';
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context,ref) {
      // Saber el usuario con riverpod
  return Scaffold(
      appBar: AppBar(
        title: const Text('Datos del usuario'),
        ),
        body: const _ConfigCountScreen(),
    );
  }
}

class _ConfigCountScreen extends ConsumerWidget {
  const _ConfigCountScreen();

  @override
  Widget build(BuildContext context,ref) {
    final colors=Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              )),
            Text('Nombre: ${ref.watch(nameProvider)}'),
            Text('Apellido: ${ref.watch(lastnameProvider)}'),
            Text('Email: ${ref.watch(emailProvider)}'),
            Text('ID Usuario: ${ref.watch(idUserProvider)}'),
            Text('Username: ${ref.watch(usernameProvider)}'),
          ],
        ),
      ),
    );
  }
}