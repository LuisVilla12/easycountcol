import 'package:flutter/material.dart';
class HistoryScreen extends StatelessWidget {
  static const String name ='history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de analisis'),),
    );
  }
}