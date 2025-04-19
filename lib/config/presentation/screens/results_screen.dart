import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  static const String name='results_screen';
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
    );
  }
}