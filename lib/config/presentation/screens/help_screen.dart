import 'package:easycoutcol/config/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpScreen extends ConsumerWidget {
  static const String name='help_name';
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context,ref) {
    final bool isDarkmode=ref.watch(isDarkModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda y soporte'),
        ),
        body: const _HelpScreen(),
    );
  }
}

class _HelpScreen extends ConsumerWidget {
  const _HelpScreen();

  @override
  Widget build(BuildContext context,ref) {
    return Placeholder();
  }
}