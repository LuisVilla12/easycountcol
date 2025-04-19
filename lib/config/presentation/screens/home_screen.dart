import 'package:easycoutcol/config/menu/side_menu.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatelessWidget {
  static const String name='home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Saber la referencia actual
    final scaffoldKey=GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio'),),
      drawer: SideMenu(scaffoldKey: scaffoldKey),
    );
  }
}