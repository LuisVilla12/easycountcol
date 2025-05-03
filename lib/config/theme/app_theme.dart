import 'package:flutter/material.dart';

// Lista de colores
const colorList=[
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.pink,
  Colors.purple
];

class AppTheme {
  
  final int selectedColor;
  final bool isDarkmode;
  
  // Clase de tema le se asigna el color
  AppTheme({
    this.selectedColor=0, 
    this.isDarkmode=false,
  }):assert(selectedColor>=0,'El color seleccionado debe ser mayor a 0'),
  assert(selectedColor<colorList.length,'El color seleccionado debe ser menor al color seleccionado');
  // assert es para el manejo de excepciones

  // Obtener el tema de la clase ThemDAta
  ThemeData getTheme ()=>ThemeData(
    useMaterial3: true,
    brightness: isDarkmode? Brightness.dark : Brightness.light,
    colorSchemeSeed: colorList[selectedColor],
    appBarTheme: const AppBarTheme(
      centerTitle: false
    )
  );
}