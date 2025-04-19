import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  static const String name='config_name';
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'),),
    );
  }
}